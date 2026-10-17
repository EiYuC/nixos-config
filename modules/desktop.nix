{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    xkb = { layout = "us"; variant = ""; };
  };
  services.displayManager.sddm = {
    enable = true;
    theme = "breeze";
    # Use X11 for the greeter; desktop sessions can still use Wayland.
    wayland.enable = false;
  };
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    elisa
  ];
}
