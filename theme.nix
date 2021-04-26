{pkgs, lib, config, ...}:

with lib;

let 
  cfg = config.home.theme;

  mkColorOption = desc: mkOption {
    type = types.str;
    description = desc;
  };
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
      type = with types; submodule {
        options = {
          foreground = mkColorOption ''The foreground color.'';
          background = mkColorOption ''The background color.'';
          black = mkColorOption
            ''The color to use for "black". (color 0)'';
          red = mkColorOption 
            ''The color to use for "red". (color 1)'';
          green = mkColorOption
            ''The color to use for "green". (color 2)'';
          yellow = mkColorOption 
            ''The color to use for "yellow". (color 3)'';
          blue = mkColorOption
            ''The color to use for "blue". (color 4)'';
          magenta = mkColorOption 
            ''The color to use for "magenta". (color 5)'';
          cyan = mkColorOption 
            ''The color to use for "cyan". (color 6)'';
          grey = mkColorOption 
            ''The color to use for "grey". (color 7)'';
          lightgrey = mkColorOption 
            ''The color to use for "light grey", also known as "bright grey". (color 8)'';
          lightred = mkColorOption 
            ''The color to use for "light red", also known as "bright red". (color 9)'';
          lightgreen = mkColorOption 
            ''The color to use for "light green", also known as "bright green". (color 10)'';
          lightyellow = mkColorOption 
            ''The color to use for "light yellow", also known as "bright yellow". (color 11)'';
          lightblue = mkColorOption 
            ''The color to use for "light blue", also known as "bright blue". (color 12)'';
          lightmagenta = mkColorOption 
            ''The color to use for "light magenta", also known as "bright magenta". (color 13)'';
          lightcyan = mkColorOption 
            ''The color to use for "light cyan", also known as "bright cyan". (color 14)'';
          white = mkColorOption "The color to use for white.";
        };
      };
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
      "*.color7"  = cfg.colors.grey;
      "*.color8"  = cfg.colors.lightgrey;
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
