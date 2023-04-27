{
  description = "Homezone NixOS k3s Cluster";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nurpkgs.url = github:nix-community/NUR;

    sops-nix.url = github:Mic92/sops-nix;
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = github:serokell/deploy-rs;
  };

  outputs = { self, nixpkgs, sops-nix, deploy-rs, ... } @ inputs:
    let
      system = "x86_64-linux";
      overlays = import ./overlays;
      inherit (inputs.nixpkgs.lib) mapAttrs;
      nixpkgs.overlays = [overlays];
    in
    rec {
      nixosConfigurations =
        import ./outputs/nixos-conf.nix { inherit inputs system sops-nix; };

      deploy.nodes = mapAttrs(node: _: {
        sshUser = "root";
        hostname = node;
        remoteBuild = true;
        fastConnection = true; # copy the entire closure to the node
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${node};
      }) {
        jables = {};
        kables = {};
        platy = {};
      };

      checks =
        let
          os = mapAttrs (_: c: c.config.system.build.toplevel) nixosConfigurations;
          deploy = mapAttrs(system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        in
        deploy;

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}
