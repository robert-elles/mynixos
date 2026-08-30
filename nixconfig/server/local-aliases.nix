# Canonical list of "<name>.local" mDNS hostname aliases for this machine.
#
# Each entry is fronted by an SSL-terminating nginx reverse proxy vhost (see
# acmeproxy.nix) and published as an address record by the mdns-aliases
# sidecar (see mdns.nix), so e.g. `https://immich.local` just works in a
# browser. `port` is the real backend to reach (the app's own internal port
# where that differs from its externally redirected one, e.g. mealie/gramps/
# openclaw which already sit behind their own SSL-terminating vhost on the
# "public" port). `path`, when set, is appended verbatim to the nginx
# proxy_pass target to rewrite onto a sub-path (see "remote"/guacamole).
[
  { name = "nextcloud"; port = 9000; }
  { name = "paperless"; port = 9001; }
  { name = "navidrome"; port = 9002; }
  { name = "jellyfin"; port = 9003; }
  { name = "mealie"; port = 19004; }
  { name = "audiobooks"; port = 9005; }
  { name = "wallabag"; port = 9006; }
  { name = "immich"; port = 9007; }
  { name = "vikunja"; port = 9008; }
  { name = "freshrss"; port = 9009; }
  { name = "rssbridge"; port = 9010; }
  {
    name = "remote";
    port = 9011;
    path = "/guacamole/";
  }
  { name = "sunshine"; port = 9012; }
  { name = "fazcast"; port = 9013; }
  { name = "newscast"; port = 9014; }
  { name = "calibre"; port = 9015; }
  { name = "gramps"; port = 19016; }
  { name = "openclaw"; port = 19017; }
  { name = "hister"; port = 9018; }
  { name = "storage"; port = 9999; }
]
