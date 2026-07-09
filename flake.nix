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
  };

  outputs = { self, nixpkgs, home-manager, thyx, ... }@inputs: {
    nixosConfigurations = {

      # --- Laptop ---
      # FIX: a previous comment here claimed this was renamed to "laptop"
      # and told you to rebuild with `--flake .#laptop` — but the attribute
      # below was never actually changed, so that command would have failed
      # with "flake does not provide attribute ... laptop". Left as
      # "nixos-t590" because users/shared.nix's `nrs` shell alias rebuilds
      # with `--flake ~/Downloads/dotfilesAI#$(hostname)`, and this
      # machine's networking.hostName (hosts/laptop/configuration.nix) is
      # also "nixos-t590" — the two need to match. Rebuild with:
      #   sudo nixos-rebuild switch --flake .#nixos-t590
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

      # ── Server ──────────────────────────────────────────────────────────
      server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };   # ADD: needed for home-manager
        modules = [
          ./hosts/server/configuration.nix
          home-manager.nixosModules.home-manager # ADD: for graintrain on server
        ];
      };

    };
  };
}
