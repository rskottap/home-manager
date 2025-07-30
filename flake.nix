{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      backupFileExtension = "backup";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    homeConfigurations.ramya = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      modules = [ 
        ./home.nix
        {
          home-manager.backupFileExtension = "backup";
        }
      ];
    };

    # For NixOS
    # Export home.nix so other flakes can use it
    homeModules = ./home.nix;
  };
}
