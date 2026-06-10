{ ... }:
{

  services.avahi = {
    enable = true;
    nssmdns4 = true; # enables .local hostname resolution via NSS
    nssmdns6 = true; # enables .local hostname resolution via NSS
    domainName = "local";
    publish = {
      enable = true;
      domain = true; # publish this machine's domain
      addresses = true; # publish this machine's address
      workstation = true; # advertise as workstation
    };
    # Publish service subdomains so they resolve via mDNS as <name>.leopard.local
    extraServiceFiles = {
      immich = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name>immich</name>
          <service>
            <type>_http._tcp</type>
            <host-name>immich.leopard.local</host-name>
            <port>9007</port>
          </service>
        </service-group>
      '';
      mealie = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name>mealie</name>
          <service>
            <type>_http._tcp</type>
            <host-name>mealie.leopard.local</host-name>
            <port>80</port>
          </service>
        </service-group>
      '';
      freshrss = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name>freshrss</name>
          <service>
            <type>_http._tcp</type>
            <host-name>freshrss.leopard.local</host-name>
            <port>80</port>
          </service>
        </service-group>
      '';
    };
  };
}
