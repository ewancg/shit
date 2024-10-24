{ pkgs, nix-homebrew, homebrew-core, homebrew-cask, ... }:
{
	system.stateVersion = 5;

	

	nixpkgs.config.allowUnfree = true;
	nixpkgs.hostPlatform = "aarch64-darwin";
	services.nix-daemon.enable = true;

	nix = {
		#nix.package = pkgs.nix;
		# idk
    package = pkgs.nixFlakes;

		# how did i end up with 3
    #extraOptions = ''
    #  experimental-features = nix-command flakes
    #'';
    #settings.experimental-features = [ "nix-command" "flakes" ];
		settings.experimental-features = "nix-command flakes";

    optimise = {
      automatic = true;
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 10d";
    };
  };

	environment.systemPackages = with pkgs; [
		vscode
	
		# Broken as of 10/24, try again whenever
		# gimme-aws-creds
		github-cli
		awscli

		tmux
		fish
		alacritty
		
		nixpkgs-fmt
		nil
		direnv
	];

	environment.shells = [pkgs.fish pkgs.bash];
	programs.fish.enable = true;

	nix-homebrew = {
	# Install Homebrew under the default prefix
	enable = true;

	# Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
	enableRosetta = true;

	# User owning the Homebrew prefix
	user = "egreen";

	# Optional: Declarative tap management
	taps = {
		"homebrew/homebrew-core" = homebrew-core;
		"homebrew/homebrew-cask" = homebrew-cask;
	};

	# Optional: Enable fully-declarative tap management
	#
	# With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
	mutableTaps = false;
};
}
