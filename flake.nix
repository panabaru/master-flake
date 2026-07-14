{
  description = "Master Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    thyx = {
      url = "github:rccyx/thyx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vpn-confinement = {
      url = "github:Maroka-chan/VPN-Confinement";
    };
  };

  outputs = { self, nixpkgs, home-manager, thyx, ... }@inputs: {
    nixosConfigurations = {

      # --- Laptop ---
      nixos-t590 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/laptop/configuration.nix
          home-manager.nixosModules.home-manager
          thyx.nixosModules.default
        ];
      };

      # --- Desktop ---
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/desktop/configuration.nix 
          home-manager.nixosModules.home-manager
          thyx.nixosModules.default          
	];
      };

     # ── Servers ──────────────────────────────────────────────────────────
      nixos-server-0 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };   # ADD: needed for home-manager
        modules = [
          ./hosts/server/configuration.nix
          home-manager.nixosModules.home-manager # ADD: for graintrain on server
	  vpn-confinement.nixosModules.default
        ];
      };

    };
  };
}
