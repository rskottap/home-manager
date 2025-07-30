{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system  = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
    in {
      homeConfigurations = rec {
        ramya = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
        };

        default = ramya;
      };

      # For NixOS
      # Export home.nix so other flakes can use it
    # For NixOS
    # Export home.nix so other flakes can use it
    nixosModules.default = { config, pkgs, ... }: {
      imports = [ ./home.nix ];
    };
  };
  }
}
