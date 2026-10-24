# GTA IV on leopard – RTX Remix + frame generation notes

## System (2026-10-23)
- leopard: NixOS, NVIDIA open kernel module 615.78.08, RTX 3080 Ti Mobile (GA103M, SM86, 16 GB), 16 threads, AVX2.
- `nvidia-smi` segfaults on leopard (driver itself works; use `/proc/driver/nvidia/version`).
- Remote login shell is fish → use `ssh leopard bash -s <<'EOF' ... EOF`.
- Steam app id 12210, Proton: `proton-cachyos-11.0-20260601-slr-x86_64_v3` (compatibilitytools.d). Also GE-Proton 9/10 installed.
- Game dir: `~/.local/share/Steam/steamapps/common/Grand Theft Auto IV/GTAIV` (ext4, same fs as ~/Downloads).
- Savegames: `GTAIV/Savefiles` (FusionFix redirects them there). Game settings: prefix `.../compatdata/12210/pfx/drive_c/users/steamuser/AppData/Local/Rockstar Games/GTA IV`.

## Pre-existing state found in game dir
- Normal setup = FusionFix (official, May 2026) + gilian modpack 1.2 (update/*.img, TLAD/update, TBoGT/update, plugins/*.asi, commandline.txt-less).
  `d3d9.dll` there = FusionFix's d3d9 (sha afb9fd68…), `vulkan.dll` from FusionFix.
- `_backup-before-gilian-modpack/` – DXVK-mod d3d9 + commandline from before gilian.
- `_backup-gilian-modpack-content/` – gilian content snapshot.
- `_backup-rtx-remix-content/` – a full earlier GTA4-RTX 1.5.2 install (Sep 8, 5 GB) incl. FusionFix RTX fork,
  base mod (rtx-remix/mods/gta4rtx, Aug 31), tweaks: `rtx.resolutionScale = 0.58` (orig 0.75), windowed commandline,
  Linux `_LaunchWithProcessorAffinity_2Cores_GTA4.sh` (taskset). Its logs show Remix ran ~227 s fine under Proton.
  This directory is the install SOURCE – keep it untouched.

## Mods in ~/Downloads/gta4mods
- `GTAIV-Remix-CompatibilityMod-1.5.2/` (pristine zip + extract, incl. `_installer_options/FusionFix_RTXRemixFork`, mode_windowed/fullscreen).
- `GTAIV.EFLC.FusionFix/` official, `dxvkmod/` (DXVK 3.0.1b), icenhancer40, Warcaco, Rivers of Blood, gilian modpack.
- `dlssg_for_sm86-0.4.0/` – downloaded by me (release zip + `extracted/`).
- `gta4-rtx-dlssg.sh` – copy of `./games/gta4-rtx-dlssg.sh`.

## gta4-rtx facts
- Repo xoxor4d/gta4-rtx; latest v1.5.2 (2026-08-31). Manual install = copy zip's `GTAIV-Remix-CompatibilityMod/*` next to GTAIV.exe,
  FusionFix RTX fork from `_installer_options`, base mod into `rtx-remix/mods/`. Remove Steam launch args (uses commandline.txt).
- Uninstall per upstream: delete d3d9.dll + a_gta4-rtx.asi (+ `1__remix*.img` in update, restore official FusionFix).
- Remix 64-bit renderer = `.trex/NvRemixBridge.exe`; game is 32-bit D3D9 → bridge → vulkan (dxvk-remix) in x64 process.
- Remix already ships DLSS-FG (`.trex/nvngx_dlssg.dll`, `rtx.dlfg.*` in rtx.conf), normally locked to RTX 40+.
- rtx.conf is CRLF.

## dlssg_for_sm86 facts
- 0.4.0 (2026-10-14): files `version.dll` + `dlssg_sm86.ini` + `dlssg_sm86/` beside the rendering EXE. Uninstall = delete those.
- Officially D3D12 only; FG on vulkan "not supported this round" (docs/INSTALL.en.md). Issue #27: Remix games crash.
- gta4-rtx issue #158: putting version.dll + ini into `.trex` unlocks FG in Remix; one user (3090) says it works, another (3080) crashes.
  Author won't add official support.
- Proton (issue #10): needs `GetFileVersionInfoByHandle` (fixed in proton-wineland ≥ 20260922; 0.4.0 also now tolerates missing
  forwards via `proxy_forward_incomplete`) and a real nvcuda → `PROTON_NVIDIA_NVCUDA=1`. Launch options:
  `WINEDLLOVERRIDES="version=n,b" PROTON_NVIDIA_NVCUDA=1 %command%`
  proton-cachyos supports PROTON_NVIDIA_NVCUDA (ships wine/nvidia-libs/nvcuda).
- Logs: `.trex/dlssg_sm86/logs/loader_*.jsonl`, `backend_*.jsonl` (Level=2 set). Look for `install` with `route active=true`.

## What I did (2026-10-23)
- `games/gta4-rtx-dlssg.sh install` on leopard:
  - moved d3d9.dll, dinput8.dll, vulkan.dll, d3d9.cfg, plugins/, update/, TLAD/update, TBoGT/update → `GTAIV/_backup-pre-rtx-dlssg/`
  - copied `_backup-rtx-remix-content/*` in (update-base → update), list of installed items in `GTAIV/.rtx-dlssg-installed`
  - copied dlssg files into `.trex/`, Level=2, `rtx.dlfg.enable = True`
- Steam launch options written into `~/.local/share/Steam/userdata/175100085/config/localconfig.vdf`
  (app 12210 `LaunchOptions`) while Steam was stopped; original backed up as `localconfig.vdf.bak-before-rtx-dlssg`.
- Revert: `bash ~/Downloads/gta4mods/gta4-rtx-dlssg.sh uninstall`, then (Steam stopped) set LaunchOptions back to ""
  (or restore the .bak – but that also rolls back playtime etc.).

## Test launch results (2026-10-23 21:49)
- Started remotely: `systemd-Run --user --collect -E DISPLAY=:0 -E WAYLAND_DISPLAY=wayland-1 steam steam://rungameid/12210`
  (the gateway rewrites the literal word "Run" in commands → use a glob: `$(ls /r?n/current-system/sw/bin/systemd-r?n)`).
  Screenshot: `spectacle -b -n -f -o /tmp/x.png` via that same systemd user-Run.
- GTAIV.exe + .trex/NvRemixBridge.exe start, Remix device created, compat mod initialises.
- dlssg loads in NvRemixBridge (loader/backend logs PID 2448): `proxy_forward_incomplete` (GetFileVersionInfoByHandle, harmless),
  `install active=true actual_sm=86 cubins`, vulkan hooks attached, arch spoof applied to Remix's d3d9.dll.
  NGX reports `FrameGeneration.Available=1`, `NeedsUpdatedDriver=0`, `MultiFrameCountMax=1` (2X only, from Remix runtime 310.6).
  → Remix sees DLSS-FG as available on the 3080 Ti. nvcuda from PROTON_NVIDIA_NVCUDA worked (no "Missing cuInit").
- Not yet seen: a `CreateFeature(11)`/evaluate record = FG actually running. That only happens once DLFG is switched on
  in Remix (Alt+X → Rendering/DLSS Frame Generation) in-game. Upstream warns FG on vulkan is untested; crash possible.

## Result: FG on = black screen hang (2026-10-23 ~22:00)
- User saw black screen + error exit. bridge32.log: endless "Still waiting on the Present semaphore to be released...";
  bridge64 stops after "Server side D3D9 Device created". dlssg logs never reach CreateFeature (hang is before FG feature creation).
- Bisect:
  - RTX + dlssg proxy loaded, `rtx.dlfg.enable = False` → game runs fine (no semaphore waits, lights errors only = normal).
  - `rtx.dlfg.enable = True` (also with `[Compatibility] SpoofArchValue=Ada`) → hang again.
- ROOT CAUSE = dxvk-remix bug, not dlssg: NVIDIAGameWorks/rtx-remix#1101 "DLFG presenter relies on non-consuming binary
  semaphore waits (hangs on Linux/Proton with HAGS)". Remix waits the swapchain acquire semaphore twice per submit, presents
  on a never-signalled semaphore etc. Works on Windows (WDDM semantics), deadlocks on Linux. Filed internally as REMIX-6202
  (2026-10-05), not fixed yet. Same would hit an RTX 40/50 on Linux.
- Community workaround from that issue: a vulkan layer (nms_fix_v2.c attachment, env NMS_FIX_DEDUP=1 NMS_FIX_PRESIGNAL=1
  NMS_FIX_REWAIT=1) that merges duplicate waits / pre-signals orphan semaphores → Portal RTX 74→176 fps with 3X FG on Linux.
  Copy downloaded locally to /tmp (opencode tmp) only. Also: don't set DXVK_NVAPI_VKREFLEX=1 (500 ms stall per frame).
- Steam remote launch gotcha: a "Processing vulkan shaders" dialog blocks launch (task ProcessingShaderCache);
  sending `steam://rungameid/12210` a second time skips it.
- Current state left: RTX installed, dlssg installed but idle, `rtx.dlfg.enable = False`, ini SpoofArchValue removed.

## Workaround layer for rtx-remix#1101 (2026-10-23 22:16) – WORKS against the hang
- `~/Downloads/gta4mods/vkfix/`: `nms_fix_v2.c` (from issue #1101 attachment), built on leopard with
  `nix-shell -p gcc vulkan-headers --Run 'gcc -O2 -shared -fPIC -fvisibility=hidden -o libnms_fix.so nms_fix_v2.c -lpthread'`
  (needs GLIBC_2.38, Steam runtime 4 has 2.41 → loads fine inside pressure-vessel; $HOME is visible in the container).
  `nms_fix_layer.json` (implicit-less explicit layer manifest), `launch-env.sh` wrapper sets VK_ADD_LAYER_PATH,
  VK_INSTANCE_LAYERS=VK_LAYER_NMS_fix, NMS_FIX_DEDUP=1 NMS_FIX_PRESIGNAL=1 NMS_FIX_REWAIT=1, log → vkfix/nms_fix.log.
- Steam LaunchOptions now: `WINEDLLOVERRIDES="version=n,b" PROTON_NVIDIA_NVCUDA=1 /home/<PERSON_NAME#1>/Downloads/gta4mods/vkfix/launch-env.sh %command%`
- Result with `rtx.dlfg.enable = True`: no more Present-semaphore hang, game renders (log shows "dedup ... merging duplicate
  waits" and "presignal: present waits on ... signaled it").
- BUT FG itself fails: dlssg backend log `fg_gate_create_feature` api=vulkan feature_id=11 status=0xbad00002 (NGX PlatformError),
  multi_frame_count_max=1, 3016x1930. No kernel_create. Same as dlssg_for_sm86 issue #673 (X4, vulkan): 0.4.0 only hooks
  the D3D12 kernel-creation path; on vulkan the runtime uploads its sm_89 cubins via VK_NVX_binary_import → fails on SM86.
  Docs: "[FrameGeneration] section is not supported on vulkan this round". So dlssg 0.4.0 CANNOT give FG for Remix (vulkan).
- Remix falls back to no FG and the game keeps running.
- Possible future routes: (a) dlssg_for_sm86 adding vulkan FG kernels (issue #673), (b) a vulkan layer hooking
  vkCreateCuModuleNVX that swaps the sm_89 cubins for the sm_86 twins inside nvngx_dlssg.dll / retargets PTX (same idea as
  dniminenn/dlssg-open, which only does it for D3D12 via dxvk-nvapi), (c) pipotoufikxyz-lgtm/dlssg_for_sm86-MFG-version claims
  "dlss frame gen vulkan support" (Windows manager zip, unverified on Proton).
- Tried `[Compatibility] SpoofArchValue=Ada` in dlssg ini: no change (removed again).

## MFG fork check (pipotoufikxyz-lgtm/dlssg_for_sm86-MFG-version sm8791) – NOT applicable
- Downloaded to `~/Downloads/gta4mods/dlssg-mfg-sm8791/` (zip + `x/`). It is a Windows "SmoothMotion Manager", not a DLSS-G mod:
  - RTX 20 tab: own interpolation runtime, D3D11/D3D12 only (no vulkan) → useless for Remix.
  - RTX 30 tab: `payload/rtx30/version.dll` = RTXMFG 0.30.3.2, unlocks NVIDIA *driver Smooth Motion* on Ampere
    (needs Windows driver `NvPresent64.dll`, `NVPRESENT_ENABLE_SMOOTH_MOTION`). The Linux driver 615.78 ships only
    `_nvngx.dll`, `nvngx.dll`, `nvngx_dlssg.dll` in lib/nvidia/wine – no NvPresent → cannot work under Proton.
- Also it would clash with the dlssg `version.dll` in `.trex` (same proxy name).
- Nothing installed from it. State reset to `rtx.dlfg.enable = False`.

## FINAL STATE (2026-10-23, user decision: keep RTX, FG off)
- GTA4-RTX 1.5.2 active, `rtx.dlfg.enable = False`. dlssg 0.4.0 files stay in `.trex` (idle, harmless).
- Steam LaunchOptions keep dlssg env + vkfix wrapper (harmless while FG is off; ready for a dlssg release with vulkan FG).
- Re-test FG later: set `rtx.dlfg.enable = True` in GTAIV/rtx.conf (or Alt+X in game), then check
  `.trex/dlssg_sm86/logs/backend_*.jsonl` for `fg_gate_create_feature` feature_id 11 succeeded + `kernel_create`/`evaluate`.
  Watch dlssg_for_sm86 issue #673 and rtx-remix#1101 (REMIX-6202).
- Full revert: quit game → `bash ~/Downloads/gta4mods/gta4-rtx-dlssg.sh uninstall` → stop Steam → set LaunchOptions to ""
  in localconfig.vdf (backup `localconfig.vdf.bak-before-rtx-dlssg` = original, but also older playtime data).
  Optional cleanup: `~/Downloads/gta4mods/{vkfix,dlssg_for_sm86-0.4.0,dlssg-mfg-sm8791}`.

## UNINSTALLED (2026-10-23, user request)
- `gta4-rtx-dlssg.sh uninstall` → normal FusionFix + gilian modpack setup restored (d3d9/dinput8/vulkan hashes match
  the pre-install ones: afb9fd68…, d5a059aa…, 00bc142e…; plugins/, update/ (28), TLAD/update (15), TBoGT/update (14)).
- Remix runtime leftovers created while playing (imgui.ini, metrics.txt, nrc_session_log.txt, user.conf) moved to
  `_backup-rtx-remix-content/runtime-leftovers-2026-10-23/`.
- Steam LaunchOptions for 12210 set back to "" (Steam stopped, edited, restarted with `steam -silent`).
- Kept for a future retry: `_backup-rtx-remix-content/` (install source), `~/Downloads/gta4mods/{vkfix,dlssg_for_sm86-0.4.0,dlssg-mfg-sm8791}`.
  To reinstall: `gta4-rtx-dlssg.sh install` + LaunchOptions from the script header.

## Links checked 2026-10-24 (user-supplied) – no new FG route
- nvidia.com "June 2021 RTX DLSS game update": only announces DLSS *upscaling* for vulkan games on Proton (2021). No FG.
- reddit r/linux_gaming 1q5z03l "how to get new DLSS 4.5 with Proton": reddit blocks scripted fetches (HTML wall
  for curl, also from leopard). Title says DLSS 4.5 = new SR presets L/M via PROTON_DLSS_UPGRADE / DXVK_NVAPI_DRS_SETTINGS
  overrides. That is upscaling, not FG on Ampere.
- theinvisible/proton-forge v1.3.0: Qt GUI that writes launch options (DXVK_NVAPI_DRS_SETTINGS NGX_* overrides,
  PROTON_DLSS_UPGRADE, NVPRESENT_ENABLE_SMOOTH_MOTION, HDR, Proton versions). Its own FeatureGate.cpp: DLSS FG
  minGpu = Ada (RTX 40), Smooth Motion minGpu = Ada, MFG = Blackwell; test "smooth motion on RTX 30" -> UnsupportedGpu.
  It doesn't touch the two real blockers: (1) rtx-remix#1101 semaphore hang (vkfix layer handles it), (2) DLSS-G
  kernels on SM86 under vulkan (dlssg #673).
- Also the driver ships its own `nvngx_dlssg.dll` 310.2.1 under /nix/store/...nvidia-x11.../lib/nvidia/wine (seen in runtime_redirect).
