{pkgs, lib, config, ...}:

with lib;

let 
  cfg = config.home.theme;
in
{
  options.home.theme = {
    name = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "Tokoyo Night";
      description= "The name of the theme to use.";
    };

    setXresources = mkOption {
      type = types.bool;
      default = false;
      description = "If true, add the colors to the xresources config.";
    };
  };

  config = mkIf (cfg.name != null) (
    let 
      themeColors = import ./. + (cfg.name + ".nix") {};
    in
    {
      xresources.properties = mkIf cfg.setXresources {
        "*.foreground" = themeColors.foreground;
        "*.background" = themeColors.background;
        "*.color0"  = themeColors.black;
        "*.color1"  = themeColors.red;
        "*.color2"  = themeColors.green;
        "*.color3"  = themeColors.yellow;
        "*.color4"  = themeColors.blue;
        "*.color5"  = themeColors.magenta;
        "*.color6"  = themeColors.cyan;
        "*.color8"  = themeColors.darkgrey;
        "*.color7"  = themeColors.grey;
        "*.color9"  = themeColors.lightred;
        "*.color10" = themeColors.lightgreen;
        "*.color11" = themeColors.lightyellow;
        "*.color12" = themeColors.lightblue;
        "*.color13" = themeColors.lightmagenta;
        "*.color14" = themeColors.lightcyan;
        "*.color15" = themeColors.white;
      };
    }
  );
}
