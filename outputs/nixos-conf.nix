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
}
