{config, pkgs, lib, ...}:

{
  # Config file for coc-nvim plugin
  xdg.configFile."nvim/coc-settings.json".source = ./coc-settings.json;
}
