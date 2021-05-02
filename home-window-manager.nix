{pkgs, config, lib, ...}:

with lib;

let
  cfg = config.home.windowManager;

  createWorkspaceColor = textColor: {
    border = cfg.backgroundColor;
    background = cfg.backgroundColor;
    text = textColor;
  };
in
{
  options.home.windowManager = {
    backgroundColor = mkOption {
      type = types.str;
      default = "#000000";
      description = "Background color for the bar.";
    };

    focusColor = mkOption {
      type = types.str;
      default = "#D4BFFF";
      description = "Color to use for a workspace or window with focus.";
    };

    activeColor = mkOption {
      type = types.str;
      default = "#A37ACC";
      description = "Color to use when a workspace or window is visible or active, but doesn't have focus.";
    };

    urgentColor = mkOption {
      type = types.str;
      default = "#FFE6B3";
      description = "Color to use when a window sets the urgent hint.";
    };

    inactiveColor = mkOption {
      type = types.str;
      default = "#8A889D";
      description = "Color to use when a window or workspace is inactive.";
    };

    fonts = mkOption {
      type = types.listOf types.str;
      default = ["monospace 10"];
      description = "List of fonts to use for text.";
    };
  };

  config = {
    xsession.windowManager.i3 = {
      enable = true;
      config = {
        bars = [
          {
            colors = {
              background = cfg.backgroundColor;

              focusedWorkspace = createWorkspaceColor cfg.focusColor;
              activeWorkspace = createWorkspaceColor cfg.activeColor;
              urgentWorkspace = createWorkspaceColor cfg.urgentColor;
              inactiveWorkspace = createWorkspaceColor cfg.inactiveColor;
            };

            position = "top";

            inherit fonts;
          }
        ];
      };
    };
  };
}
