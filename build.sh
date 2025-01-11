NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs/archive/3f0a8ac25fb6.tar.gz \
  nix-shell -p nixos-generators --run "nixos-generate --format qcow --configuration ./image.nix -o result"