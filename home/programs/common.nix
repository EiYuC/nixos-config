{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    libgcc libclang gcc (lib.setPrio 20 clang) binutils nodejs_26 codex qq
  ];
}
