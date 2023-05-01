{ inputs, system, sops-nix, ... }:

let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  pkgs = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };

  commonModules = [
    ../configuration.nix
    sops-nix.nixosModules.sops
  ];
in
{
  kables = nixosSystem {
    inherit pkgs system;
    specialArgs = { inherit inputs; };
    modules = commonModules ++ [ ../nodes/kables.nix ];
  };

  platy = nixosSystem {
    inherit pkgs system;
    specialArgs = { inherit inputs; };
    modules = commonModules ++ [ ../nodes/platy.nix ];
  };

  jables = nixosSystem {
    inherit pkgs system;
    specialArgs = { inherit inputs; };
    modules = commonModules ++ [ ../nodes/jables.nix ];
  };

	ljesus = nixosSystem {
		inherit pkgs system;
		specialArgs = { inherit inputs; };
		modules = commonModules ++ [ ../nodes/ljesus.nix ];
  };

  lamey = nixosSystem {
    pkgs = import inputs.nixpkgs {
      system = "armv7l-linux";
      config.allowUnfree = true;
    };
    system = "armv7l-linux";
    specialArgs = { inherit inputs; };
    modules = commonModules ++ [ ../nodes/lamey.nix ];
  };
}
