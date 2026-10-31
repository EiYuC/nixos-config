{
  description = "NixOS and Home Manager configuration for cao";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "git+https://github.com/nix-community/home-manager?ref=master&shallow=1";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/nixos ];
    };

    homeConfigurations."cao@nixos" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ (import ./overlays/downloads.nix) ];
      };
      extraSpecialArgs = { inherit inputs; };
      modules = [ ./home ];
    };
  };
}
