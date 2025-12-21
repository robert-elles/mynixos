{ settings, pkgs-pin, ... }:
{
  # services.dnsmasq = {
  #   enable = true;
  #   setings.servers = [
  #     "1.1.1.1"
  #     "9.9.9.9"
  #   ];
  # };

  services.coredns.enable = true;
  # services.coredns.package = pkgs-pin.coredns;
  services.coredns.config = ''
    . {
      # Cloudflare and Google
      forward . 1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4
      cache
    }

    ${settings.public_hostname} {
      template IN A  {
          answer "{{ .Name }} 0 IN A ${settings.ipfalcon}"
      }
    }

    ${settings.public_hostname2} {
      template IN A  {
          answer "{{ .Name }} 0 IN A ${settings.ipfalcon}"
      }
    }
  '';
}
