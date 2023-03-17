{
  description = "Homezone NixOS k3s Cluster";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nurpkgs.url = github:nix-community/NUR;

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, sops-nix, ... } @ inputs:
    let
      system = "x86_64-linux";
      inherit (inputs.nixpkgs.lib) mapAttrs;
    in
    rec {
      nixosConfigurations =
        import ./outputs/nixos-conf.nix { inherit inputs system sops-nix; };

      checks.${system} =
        let
          os = mapAttrs (_: c: c.config.system.build.toplevel) nixosConfigurations;
        in
        os;

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}
