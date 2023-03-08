{ config, pkgs, ... }:

{
	environment.variables.EDITOR = "nvim";

	programs.neovim = {
		enable = true;
		viAlias = true;
		vimAlias = true;

		configure = {
			customRC = ''
				set number shiftwidth=2 tabstop=2 softtabstop
			'';

			packages.myVimPackage = with pkgs.vimPlugins; {
				start = [
					vim-nix
				];
			};
		};

	};
}
