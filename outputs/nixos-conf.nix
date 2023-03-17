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

    lamey = nixosSystem {
        inherit pkgs;
        system = "armv7l-linux";
		specialArgs = { inherit inputs; };
		modules = commonModules ++ [ ../nodes/lamey.nix ];
    };
}
