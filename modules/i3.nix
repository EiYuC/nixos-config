{ pkgs, ... }:
{
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = [ pkgs.i3blocks ];
    extraSessionCommands = ''
      export GTK_IM_MODULE=fcitx
      export QT_IM_MODULE=fcitx
      export XMODIFIERS=@im=fcitx
    '';
  };
  services.libinput.enable = true;
  services.udisks2.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.i3.default = [ "gtk" ];
  };
}
