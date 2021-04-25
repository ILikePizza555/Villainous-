{pkgs, lib, config, ...}:

with lib;

let 
  cfg = config.home.theme;
in
{
  options.home.theme = {
    enable = mkEnableOption "Home-manager theme module";

    name = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "Tokoyo Night";
      description= "The name of the theme.";
    };

    colors = mkOption {
      type = types.attrsOf types.str;
      description = "The colors defined by the theme.";
    };

    setXresources = mkOption {
      type = types.bool;
      default = false;
      description = "If true, add the colors to the xresources config.";
    };
  };

  config = mkIf cfg.enable {
    xresources.properties = mkIf cfg.setXresources {
      "*.foreground" = cfg.colors.foreground;
      "*.background" = cfg.colors.background;
      "*.color0"  = cfg.colors.black;
      "*.color1"  = cfg.colors.red;
      "*.color2"  = cfg.colors.green;
      "*.color3"  = cfg.colors.yellow;
      "*.color4"  = cfg.colors.blue;
      "*.color5"  = cfg.colors.magenta;
      "*.color6"  = cfg.colors.cyan;
      "*.color8"  = cfg.colors.darkgrey;
      "*.color7"  = cfg.colors.grey;
      "*.color9"  = cfg.colors.lightred;
      "*.color10" = cfg.colors.lightgreen;
      "*.color11" = cfg.colors.lightyellow;
      "*.color12" = cfg.colors.lightblue;
      "*.color13" = cfg.colors.lightmagenta;
      "*.color14" = cfg.colors.lightcyan;
      "*.color15" = cfg.colors.white;
    };
  };
}
