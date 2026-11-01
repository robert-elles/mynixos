{ settings, ... }:
{
  # Reverse proxy, hub redirect and mDNS name come from the "karakeep" entry
  # in local-aliases.nix (see acmeproxy.nix).
  services.karakeep = {
    enable = true;
    extraEnvironment = {
      PORT = "9021";
      # Public-domain name, so it works on clients without the local CA.
      NEXTAUTH_URL = "https://karakeep.${settings.public_hostname2}";
      # Leave signups open until the first (admin) account exists, then
      # set to "true".
      DISABLE_SIGNUPS = "false";
      DISABLE_NEW_RELEASE_CHECK = "true";
    };
  };
}
