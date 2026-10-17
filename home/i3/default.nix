{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    i3blocks feh dunst networkmanagerapplet
    polkit_gnome xss-lock i3lock xsetroot xset xrandr
    brightnessctl playerctl pulseaudio pavucontrol
  ];
  xsession.enable = true;
  systemd.user.services.i3-lid-display = {
    Unit = {
      Description = "Turn the i3 internal display off/on with the laptop lid";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.bash}/bin/bash ${./scripts/lid-display}";
      Environment = "PATH=${lib.makeBinPath [ pkgs.xrandr pkgs.gawk pkgs.gnugrep pkgs.coreutils ]}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
  xdg.configFile = {
    "i3/config".source = ./config;
    "i3/keybindings".source = ./keybindings;
    "i3/i3blocks.conf".source = ./i3blocks.conf;
    "i3/scripts" = { source = ./scripts; recursive = true; };
    "i3/polkit-agent" = {
      executable = true;
      text = "#!/bin/sh\nexec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1\n";
    };
  };
  xdg.dataFile = lib.optionalAttrs (builtins.pathExists ../../wallpaper.jpg) {
    "wallpapers/wallpaper.jpg".source = ../../wallpaper.jpg;
  };
}
