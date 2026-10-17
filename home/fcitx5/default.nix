{ lib, pkgs, ... }:
let
  dataDir = ./rime-data-flypy;
  # Individual source links leave build/ and user dictionaries writable.
  rimeFiles = lib.filterAttrs (name: _: name != "README.md")
    (builtins.listToAttrs (map (path: {
      name = lib.removePrefix "${toString dataDir}/" (toString path);
      value = path;
    }) (lib.filesystem.listFilesRecursive dataDir)));
  hasSchema = lib.any (name: lib.hasSuffix ".schema.yaml" name) (builtins.attrNames rimeFiles);
  ini = pkgs.formats.ini { };
in
{
  # Kitty's GLFW frontend uses Fcitx5's IBus compatibility interface on X11.
  home.sessionVariables.GLFW_IM_MODULE = "ibus";
  xdg.configFile."fcitx5/profile".source = ini.generate "fcitx5-profile" {
    "Groups/0" = {
      Name = "Default";
      "Default Layout" = "us";
      DefaultIM = if hasSchema then "rime" else "pinyin";
    };
    "Groups/0/Items/0" = { Name = "keyboard-us"; Layout = ""; };
    "Groups/0/Items/1" = { Name = if hasSchema then "rime" else "pinyin"; Layout = ""; };
    "Groups/0/Items/2" = { Name = if hasSchema then "pinyin" else "rime"; Layout = ""; };
    GroupOrder."0" = "Default";
  };
  xdg.dataFile = lib.mapAttrs' (name: source:
    lib.nameValuePair "fcitx5/rime/${name}" { inherit source; }
  ) rimeFiles;
  home.activation.configurePlasmaInputMethod = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
      --file kwinrc --group Wayland --key InputMethod \
      /run/current-system/sw/share/applications/org.fcitx.Fcitx5.desktop
  '';
}
