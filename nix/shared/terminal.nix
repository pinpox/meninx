{
  config,
  pkgs,
  ...
}: {
  # Show password feedback on sudo
  security.sudo.extraConfig = "Defaults pwfeedback";

  # Include .local/bin in path
  environment.localBinInPath = true;

  # Set global environment variables
  environment.variables = {
    FLAKE = "/home/sonar/Nix";
    NIXOS_OZONE_WL = "1";
  };

  # Permit all shells for user accounts
  environment.shells = with pkgs; [bashInteractive zsh];

  # Set default shell to zsh
  users.defaultUserShell = pkgs.zsh;

  # Tune up bash a little
  programs.bash = {
    # Defaults
    enableCompletion = true;
    enableLsColors = true;

    # Nicer line editor and completion
    blesh.enable = true;
  };

  # Enable and basic options for zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };
}
