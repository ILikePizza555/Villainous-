{config, pkgs, lib, ...}:

{
  # Config file for coc-nvim plugin
  xdg.configFile."nvim/coc-settings.json".source = ./loose_configs/coc-settings.json;
}
