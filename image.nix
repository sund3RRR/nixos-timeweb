{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: 
let
  qemu-ga-wrapped = pkgs.callPackage ./pkgs/ga-wrapped.nix { };
  setup-timeweb-nixos = pkgs.writeScriptBin "setup-timeweb-nixos" (builtins.readFile ./scripts/setup-timeweb-nixos.sh);
in 
{
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

  services.qemuGuest.enable = true;
  services.qemuGuest.package = qemu-ga-wrapped;

  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  services.openssh.settings.PermitRootLogin = "yes";

  services.zabbixAgent = {
    enable = true;
    server = "92.53.116.12,92.53.116.111,92.53.116.119,217.18.62.11";
    settings = {
      StartAgents = 3;
      DebugLevel = 3;
      
      AllowRoot = 0;
      User = "zabbix";
      Timeout = 30;
      DenyKey = "system.run[*]";
      
      UserParameter = "timeweb_config_version,echo 127";
    };
    openFirewall = true;
  };

  environment.systemPackages = [
    setup-timeweb-nixos
  ];

  environment.etc."nixos/example-configuration.nix" = {
    mode = "0644";
    text = (builtins.readFile ./config/configuration.nix);
  };

  environment.etc."nixos/ga-wrapped.nix" = {
    mode = "0644";
    text = (builtins.readFile ./pkgs/ga-wrapped.nix);
  };

  system.stateVersion = "23.11";
}
