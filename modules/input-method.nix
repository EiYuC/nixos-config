{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [ qt6Packages.fcitx5-chinese-addons fcitx5-gtk fcitx5-rime ];
      waylandFrontend = true;
    };
  };

  environment.sessionVariables.QT_IM_MODULES = "wayland;fcitx;ibus";
}
