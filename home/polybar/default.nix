{ config, lib, pkgs, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = [ pkgs.nerd-fonts.symbols-only pkgs.noto-fonts ];

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override { i3Support = true; pulseSupport = true; };
    config = ./config.ini;
    script = ''
      polybar --reload main &
    '';
  };

  # Start from i3 only. A systemd unit prevents duplicate bars on i3 restart.
  systemd.user.services.polybar = {
    Unit.PartOf = lib.mkForce [ "graphical-session.target" ];
    Install.WantedBy = lib.mkForce [ ];
    Service.Environment = lib.mkForce [
      "PATH=${lib.makeBinPath [ config.services.polybar.package pkgs.rofi pkgs.pavucontrol pkgs.kitty pkgs.networkmanager pkgs.bash pkgs.coreutils ]}:/run/current-system/sw/bin:/home/cao/.nix-profile/bin"
    ];
  };
}
