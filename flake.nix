{
  description = "NixOS 25.11 with COSMIC, GRUB, btrfs, ZRAM";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # You can add more inputs later (e.g. hardware, etc.)
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations."coshmar" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
        ];
      };
    };
}
