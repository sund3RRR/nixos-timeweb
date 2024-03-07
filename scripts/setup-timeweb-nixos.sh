nixos-generate-config
cp /etc/nixos/example-configuration.nix /etc/nixos/configuration.nix
mkdir /etc/nixos/pkgs
cp /etc/nixos/ga-wrapped.nix /etc/nixos/pkgs/ga-wrapped.nix

nixos-rebuild switch --upgrade