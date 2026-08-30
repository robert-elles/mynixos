{
  lib,
  pkgs,
  ...
}:
let
  iface = "eno1";
  # (name, port) pairs to publish as "<name>.local" on this machine's iface address.
  aliases = [
    {
      name = "immich";
      port = 9007;
    }
  ];

  pythonEnv = pkgs.python3.withPackages (ps: [ ps.zeroconf ]);

  mdnsAliasesScript = pkgs.writeText "mdns-aliases.py" ''
    """Publish extra "<name>.local" hostname aliases on ${iface}'s address.

    Avahi always publishes a reverse PTR record alongside every forward
    address it adds, without allowing more than one owner per IP
    (confirmed in avahi-core/entry.c: avahi_server_add_address() /
    check_record_conflict()). Since ${iface}'s address already
    reverse-maps to this machine's own hostname, Avahi rejects any
    *second* name pointed at the same IP as a "Local name collision" -
    that's a hard Avahi limitation, not a config bug, and there is no
    supported way to opt a static host entry out of the reverse record.

    python-zeroconf has no such restriction (it never auto-publishes a
    reverse PTR) and deliberately sets SO_REUSEPORT/SO_REUSEADDR on its
    mDNS socket so it coexists with Avahi on port 5353. So Avahi keeps
    handling everything else (this machine's own hostname, DNS-SD
    browsing, NSS integration) and this sidecar only answers "<name>.local"
    address queries for the aliases above, on ${iface}'s real IP.
    """

    import fcntl
    import logging
    import signal
    import socket
    import struct
    import time

    from zeroconf import ServiceInfo, Zeroconf

    IFACE = "${iface}"
    ALIASES = ${
      lib.concatStrings [
        "["
        (lib.concatMapStrings (a: ''("${a.name}", ${toString a.port}), '') aliases)
        "]"
      ]
    }
    POLL_INTERVAL_SECS = 60
    SIOCGIFADDR = 0x8915

    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
    log = logging.getLogger("mdns-aliases")

    running = True


    def _stop(signum, frame):
        global running
        running = False


    signal.signal(signal.SIGTERM, _stop)
    signal.signal(signal.SIGINT, _stop)


    def get_ipv4(ifname: str) -> str | None:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            packed = struct.pack("256s", ifname.encode()[:15])
            return socket.inet_ntoa(fcntl.ioctl(s.fileno(), SIOCGIFADDR, packed)[20:24])
        except OSError:
            return None
        finally:
            s.close()


    def wait_for_ip(ifname: str) -> str:
        while running:
            ip = get_ipv4(ifname)
            if ip:
                return ip
            log.warning("waiting for %s to get an address", ifname)
            time.sleep(5)
        raise SystemExit(0)


    def main() -> None:
        ip = wait_for_ip(IFACE)
        zc = Zeroconf(interfaces=[ip])
        infos = {
            name: ServiceInfo(
                "_mdnsalias._tcp.local.",
                f"{name}._mdnsalias._tcp.local.",
                port=port,
                server=f"{name}.local.",
                parsed_addresses=[ip],
            )
            for name, port in ALIASES
        }
        try:
            for info in infos.values():
                zc.register_service(info)
            log.info("published %s -> %s on %s", list(infos), ip, IFACE)

            while running:
                time.sleep(POLL_INTERVAL_SECS)
                current = get_ipv4(IFACE)
                if current and current != ip:
                    log.info("%s address changed %s -> %s, republishing", IFACE, ip, current)
                    ip = current
                    for info in infos.values():
                        info.addresses = [socket.inet_aton(ip)]
                        zc.update_service(info)
        finally:
            for info in infos.values():
                zc.unregister_service(info)
            zc.close()


    if __name__ == "__main__":
        main()
  '';
in
{
  services.avahi = {
    enable = true;
    nssmdns4 = true; # enables .local hostname resolution via NSS
    nssmdns6 = true; # enables .local hostname resolution via NSS
    domainName = "local";
    # Without this, Avahi also listens on every podman/docker bridge and
    # veth interface, publishing this machine's hostname on a random
    # container link-local address instead of a real LAN one.
    allowInterfaces = [ iface ];
    publish = {
      enable = true;
      domain = true; # publish this machine's domain
      addresses = true; # publish this machine's address
      workstation = true; # advertise as workstation
    };
    # DNS-SD announcements for the aliases above, so they also show up when
    # browsing for _http._tcp services. The address behind each host-name
    # is published separately by the mdns-aliases sidecar below.
    extraServiceFiles = {
      immich = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name>immich</name>
          <service>
            <type>_http._tcp</type>
            <host-name>immich.local</host-name>
            <port>9007</port>
          </service>
        </service-group>
      '';
      #   mealie = ''
      #     <?xml version="1.0" standalone='no'?>
      #     <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      #     <service-group>
      #       <name>mealie</name>
      #       <service>
      #         <type>_http._tcp</type>
      #         <host-name>mealie.leopard.local</host-name>
      #         <port>80</port>
      #       </service>
      #     </service-group>
      #   '';
      #   freshrss = ''
      #     <?xml version="1.0" standalone='no'?>
      #     <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      #     <service-group>
      #       <name>freshrss</name>
      #       <service>
      #         <type>_http._tcp</type>
      #         <host-name>freshrss.leopard.local</host-name>
      #         <port>80</port>
      #       </service>
      #     </service-group>
      #   '';
    };
  };

  systemd.services.mdns-aliases = {
    description = "Publish extra .local hostname aliases via a lightweight mDNS responder";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pythonEnv}/bin/python3 ${mdnsAliasesScript}";
      Restart = "always";
      RestartSec = "5s";
      DynamicUser = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };
}
