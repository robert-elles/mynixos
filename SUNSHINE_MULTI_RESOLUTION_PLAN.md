# Sunshine Virtual Display: Multiple Selectable Resolutions

## Goal

Leopard's Sunshine setup (`nixconfig/server/remotecontrol.nix`) streams from a
forced-EDID virtual display on `HDMI-A-1` (`machines/leopard/hardware.nix`),
currently fixed at 3024x1964 (MacBook Pro 14" *physical* Retina resolution,
same 1.54 aspect ratio as the logical 1512x982). Want to also offer a 32:9
ultrawide resolution (3840x1080) so it can be picked when connecting with
Moonlight, without giving up the 3024x1964 option.

Not done yet — this file is the state of the investigation so the work can
be picked up later.

---

## Current state (done)

- `hardware.nix`: `hardware.display.edid.modelines."MBP60"` forces
  `HDMI-A-1` connected at boot via kernel params (`drm.edid_firmware=...`,
  `video=HDMI-A-1:e`), single mode 3024x1964@60.
- Modeline computed with the VESA CVT algorithm, verified byte-for-bit
  against the Linux kernel's `drm_cvt_mode()` (`drivers/gpu/drm/drm_modes.c`)
  using the previous known-good 1920x1080@60 modeline as ground truth before
  trusting it for new resolutions. See the CVT constants/algorithm there if
  more resolutions need computing later (kernel source is the most reliable
  reference — don't hand-derive from memory without cross-checking).
- Had to append `ratio=16:10` to the modeline string — see "EDID ratio field
  limitation" below.
- First shipped at 1512x982 (the MacBook's *logical/points* resolution), but
  that left a black border around the video in Moonlight: the client window
  didn't shrink to match, and with scaling set to not-upscale it centered the
  smaller frame instead of filling the window. Switched to 3024x1964 (exact
  physical pixel count, same aspect ratio) so a fullscreen Moonlight session
  maps 1:1 to the panel with no scaling needed. If a black border reappears,
  suspect a Moonlight-side scaling/resolution setting (see prior turn in
  conversation history) before assuming the host config is wrong again.

---

## Key insights from investigation

### The `hardware.display` module

`hardware.display.edid.modelines` / `hardware.display.outputs` is a **NixOS
core module** (`nixos/modules/services/hardware/display.nix`), not something
from chaotic/nyx. Each named modeline becomes its own EDID binary
(`edid/<name>.bin`) built via `pkgs.edid-generator`
(`akatrevorjay/edid-generator`, script `modeline2edid`). `hardware.display.
outputs."<connector>"` binds exactly one `.bin` file to one connector name
and forces it enabled via kernel param.

### One modeline = one single-mode EDID — no built-in multi-resolution support

`modeline2edid` generates **exactly one detailed timing descriptor (DTD)**
per named Modeline, i.e. one fixed resolution per `.bin` file
(`edid.S` template only fills `descriptor1` from the single modeline given).
There is no way to combine multiple Modelines into one multi-mode EDID using
this tool — each name is a fully separate, single-resolution EDID. This is
also **baked in at boot** via kernel cmdline, not swappable at runtime by
itself.

Practical consequence: you cannot get "one virtual display, multiple
selectable modes" for free from this module. Real monitors can advertise
multiple DTDs / CTA-861 extension block modes; this generator doesn't
support writing one.

### EDID 1.3 ratio field limitation (why the build failed)

`modeline2edid`'s ratio auto-detector (`find-supported-ratio`) only
recognizes **16:10, 16:9, 4:3, 5:4** — EDID 1.3's `XY_RATIO` field is only 2
bits, hardcoded to those four values in `edid.S`
(`XY_RATIO_16_10/4_3/5_4/16_9`). Any other ratio (e.g. 1512:982 ≈ 1.54) fails
auto-detection ("Computed ratio: UNKNOWN") and aborts the build. Fix: pass an
explicit `ratio=<closest match>` (or `xy_ratio=`) token appended to the
modeline string — `template-S` parses trailing tokens for
`ratio=*|xy_ratio=*` and skips auto-detection. This only affects the EDID's
supplementary "standard timing" byte, not the actual DTD geometry, so
picking the nearest ratio is cosmetically imperfect but functionally fine.

3840:1080 is exactly 32:9 = 3.556, also not one of the four — will need the
same `ratio=` override treatment (nearest is 16:9, still a rough match,
doesn't matter functionally).

### Sunshine's own documented pattern for per-app resolution switching

While checking exact syntax in `nixos/modules/services/networking/sunshine.
nix`, found the module's own doc example:

```nix
services.sunshine.applications.apps = [
  {
    name = "1440p Desktop";
    prep-cmd = [{
      do   = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-4.mode.2560x1440@144";
      undo = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-4.mode.3440x1440@144";
    }];
    exclude-global-prep-cmd = "false";
    auto-detach = "true";
  }
];
```

This is the officially-intended idiom: one Sunshine "app" per resolution,
each with a `prep-cmd` that runs `kscreen-doctor output.<name>.mode.<W>x<H>@
<Hz>` before the stream starts and reverses it (`undo`) after. **This
assumes the output already has multiple modes available** (a real monitor
with a proper multi-mode EDID) — it does not apply directly to our
single-mode virtual EDID.

### Sunshine's `output_name` and the existing output-index fragility

`services.sunshine.settings.output_name = 0` in `remotecontrol.nix` selects
capture by **index into currently-active/enabled outputs**, not by stable
connector name. This is already a documented pain point in this repo — see
the long comments in `machines/leopard/flake.nix` around
`keep-outputs-enabled` and the various "Couldn't find monitor [0]" failure
modes (lid close, KWin's `kwinoutputconfig.json` replay, idle-timeout
display-off all shift which index is "0"). Any approach involving toggling
a second output on/off at stream time inherits this same fragility.

---

## Two candidate approaches

### Option A — second physical output, enable/disable toggle

- Requires a second **real, unused** connector on the same GPU (`card0`,
  Nvidia — the one HDMI-A-1 is wired to) with nothing physically plugged in.
  Not yet confirmed what's available; would need to check
  `/sys/class/drm/card0-*` on leopard itself.
- Add a second `hardware.display.edid.modelines."UW32x9"` (3840x1080) bound
  to that connector, forced enabled at boot same as HDMI-A-1.
- Both outputs would be simultaneously connected/enabled at boot by default
  → KWin would extend the desktop across both. Needs explicit layout
  handling (position, disable-by-default) to avoid that.
- Two Sunshine apps, each `prep-cmd` doing
  `kscreen-doctor output.<mine>.enable` + `output.<other>.disable` (and
  `undo` reversing), so `output_name = 0` always resolves to "the one
  currently enabled".
- **Risk**: directly exercises the same enable/disable + output-index
  mechanism already responsible for the documented "Couldn't find monitor
  [0]" bugs on this machine. Not free of risk just because the existing
  `keep-outputs-enabled` watcher exists — that watcher fights a related but
  different failure mode (KWin disabling things unprompted).

### Option B — single output, hand-crafted multi-mode EDID (matches Sunshine's own idiom)

- Keep `HDMI-A-1` as the only virtual output — no second connector needed.
- Replace the `hardware.display.edid.modelines` helper (which can't do this)
  with a custom-built EDID binary containing **two detailed timing
  descriptors** (1512x982 and 3840x1080), so KWin sees HDMI-A-1 as a normal
  multi-mode monitor.
- Two Sunshine apps, each `prep-cmd` = `kscreen-doctor output.HDMI-A-1.mode.
  <W>x<H>@60`, `undo` = switch back — exactly the pattern from the
  sunshine.nix module's own example.
- `output_name` stays fixed at `0`/HDMI-A-1 throughout — avoids the
  output-index fragility of Option A entirely.
- **Cost**: need to write/generate the EDID bytes directly (a `runCommand`
  derivation producing the `.bin`, e.g. by extending `edid-generator`'s
  `edid.S` template to accept a second DTD, or constructing the binary
  another way — EDID format is well documented, this is doable but is real
  implementation work, not a config tweak).

### Recommendation (tentative, not yet decided with user)

Option B is architecturally cleaner and matches Sunshine's documented
pattern, at the cost of more up-front EDID-crafting work. Option A reuses
existing tooling as-is but inherits a bug class this repo has already spent
significant effort defending against. Leaning toward B if/when this is
picked back up — but worth re-confirming appetite for the EDID-crafting
effort vs. just accepting Option A's fragility, before starting.

---

## Next steps if resumed

1. Decide between Option A and Option B (see tradeoffs above).
2. If Option A: SSH to leopard, inspect `/sys/class/drm/card0-*` for a free
   connector name to force-enable.
3. If Option B: prototype a two-DTD EDID derivation (extend
   `edid-generator`'s `modeline2edid`/`edid.S`, or write the binary
   directly) and validate with `edid-decode` before wiring into
   `hardware.nix`.
4. Add `services.sunshine.applications.apps` entries in
   `nixconfig/server/remotecontrol.nix` with the appropriate `prep-cmd`s for
   whichever option is chosen.
5. Compute the 3840x1080@60 modeline if not reusing the one already derived
   during this investigation: `346.00  3840 4088 4496 5152  1080 1083 1093
   1120 -hsync +vsync` (verified via the same kernel-`drm_cvt_mode`
   cross-check as the 1512x982 one; will need a `ratio=16:9` override like
   MBP60 needed `ratio=16:10`).
