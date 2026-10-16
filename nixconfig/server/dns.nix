{ settings, pkgs-pin, ... }:
let
  # LAN address of this machine (eno1). Everything under the internal
  # TLD resolves here; nginx then separates the services by SNI/Host
  # rather than by port (see acmeproxy.nix).
  serverIp = settings.server_ip;
  routerIp = settings.router_ip;
  domain = settings.internal_domain;
  publicDomain = settings.public_hostname2;
in
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
    # Internal TLD for this host's services: "<name>.${domain}" (e.g.
    # https://feishin.${domain}). Everything in the zone, including the bare
    # apex, answers with this machine's LAN address; nginx picks the service
    # apart by Host/SNI on 443 (see acmeproxy.nix), so no per-service port
    # is needed.
    #
    # ".${domain}" is reserved by ICANN for private use and is never
    # delegated publicly, so it cannot collide with a real domain. It only
    # resolves for clients that use this machine as their resolver (set via
    # the wireguard config).
    ${domain} {
      template IN A {
        answer "{{ .Name }} 60 IN A ${serverIp}"
      }
      # Same name, no AAAA: answer NODATA instead of letting it fall through,
      # or dual-stack clients would hang waiting on an IPv6 answer.
      template IN AAAA {
        rcode NOERROR
      }
    }

    # Split horizon for the public (dynu) domain: it is registered and
    # resolves to this connection's public address on the internet, but
    # inside the network the services are only reachable on the LAN, so the
    # same names answer with the LAN address here. That is what makes the
    # Let's Encrypt wildcard (see acmeproxy.nix) usable without exposing
    # anything: a real, publicly trusted cert on a private address.
    ${publicDomain} {
      template IN A {
        answer "{{ .Name }} 60 IN A ${serverIp}"
      }
      template IN AAAA {
        rcode NOERROR
      }
    }

    . {
      # The router first: it is authoritative for the LAN's DHCP hostnames
      # ("leopard", "*.fritz.box"), which no public resolver knows. Clients
      # that use this machine as their only resolver would otherwise lose
      # every local name. `policy sequential` keeps that order instead of
      # load-balancing across all upstreams; on failure it falls through to
      # Cloudflare and Google for the public internet.
      forward . ${routerIp} 1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4 {
        policy sequential
      }
      cache
    }

    # ${settings.public_hostname} {
    #   template IN A  {
    #      answer "{{ .Name }} 0 IN A {settings.server_ip}"
    #   }
    # }

    # ${settings.public_hostname2} {
    #   template IN A  {
    #       answer "{{ .Name }} 0 IN A {settings.server_ip}"
    #   }
    # }
  '';
}
