{ inputs, system, sops-nix, overlays, ... }:

let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  pkgs = import inputs.nixpkgs {
    inherit system overlays;
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

  belakay = nixosSystem {
    inherit pkgs system;
    specialArgs = { inherit inputs; };
    modules = commonModules ++ [ ../nodes/belakay.nix ];
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
