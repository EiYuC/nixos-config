{ config, pkgs, ... }:

let
  lidPolicy = pkgs.writeShellScript "lid-power-policy" ''
    # Only act on a closed lid. Also recheck when external power changes.
    closed=false
    for lid in /proc/acpi/button/lid/*/state; do
      if ${pkgs.gnugrep}/bin/grep -q closed "$lid" 2>/dev/null; then
        closed=true
      fi
    done
    "$closed" || exit 0

    for supply in /sys/class/power_supply/*; do
      [ -r "$supply/online" ] || continue
      read -r online < "$supply/online"
      [ "$online" = 1 ] && exit 0
    done

    ${pkgs.systemd}/bin/systemctl suspend
  '';
in
{
  # acpid applies the same AC/battery policy even with an external monitor.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    IdleAction = "ignore";
  };
  # Reload the lid policy on rebuild without restarting the active X11 session.
  systemd.services.systemd-logind.reloadTriggers = [
    config.environment.etc."systemd/logind.conf".source
  ];
  services.acpid = {
    enable = true;
    lidEventCommands = "${lidPolicy}";
    acEventCommands = "${lidPolicy}";
  };
}
