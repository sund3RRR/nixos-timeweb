{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  # for virtio kernel drivers
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  boot.growPartition = true;
  boot.kernelParams = ["console=ttyS0"];
  boot.loader.grub.device = "/dev/vda";
  boot.loader.timeout = 0;

  networking.useDHCP = true;
  networking.dhcpcd.persistent = true;
  networking.dhcpcd.extraConfig = ''
    option rfc3442-classless-static-routes code 121 = array of unsigned integer 8;
    option dhcp6.next-hop code 242 = ip6-address;

    send host-name = gethostname();
    request subnet-mask, broadcast-address, time-offset, routers,
        domain-name, domain-name-servers, domain-search, host-name,
        dhcp6.name-servers, dhcp6.domain-search, dhcp6.fqdn, dhcp6.sntp-servers,
        netbios-name-servers, netbios-scope, interface-mtu,
        rfc3442-classless-static-routes, ntp-servers, dhcp6.next-hop;

    timeout 300;
  '';

  users.users.root.password = "1234";

  services.qemuGuest.enable = true;

  services.openssh.enable = true;
  services.openssh.openFirewall = true;

  services.zabbixServer.enable = true;
  services.zabbixServer.openFirewall = true;
  services.zabbixAgent = {
    enable = true;
    server = "0.0.0.0";
  };
}
