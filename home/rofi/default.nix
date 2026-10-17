{ ... }:
{
  programs.rofi = {
    enable = true;
    theme = ./configs/arc_dark_colors.rasi;
    settings = { modi = "drun,run,window"; show-icons = true; terminal = "kitty"; };
  };
  xdg.configFile."rofi/configs" = { source = ./configs; recursive = true; };
}
