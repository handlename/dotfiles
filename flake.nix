{
  description = "Darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      darwin,
      ...
    }:
    let
      system = "aarch64-darwin";
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      overlayUnstable = final: prev: {
        inherit (unstable) gh gopls;
      };
      pkgs = import nixpkgs {
        system = system;
        config.allowUnfree = true;
        overlays = [ overlayUnstable ];
      };
    in
    {
      homeConfigurations."current" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [
          ./home.nix
        ];
        extraSpecialArgs = {
          inherit inputs;
          username = "handlename";
        };
      };

      homeConfigurations."old" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [
          ./home.nix
        ];
        extraSpecialArgs = {
          inherit inputs;
          username = "nagata-hiroaki";
        };
      };

      darwinConfigurations."current" = darwin.lib.darwinSystem {
        system = system;
        modules = [
          ./configuration.nix
          ./darwin.nix
        ];
        specialArgs = {
          inherit inputs;
          username = "handlename";
        };
      };

      darwinConfigurations."old" = darwin.lib.darwinSystem {
        system = system;
        modules = [
          ./configuration.nix
          ./darwin.nix
        ];
        specialArgs = {
          inherit inputs;
          username = "nagata-hiroaki";
        };
      };
    };
}
