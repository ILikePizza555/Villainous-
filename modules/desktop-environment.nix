{pkgs, config, lib, ...}:

let
  # Import our own library.
  lib = lib.extends (self: super: import ../lib {lib = super; });

  cfg = config.home.desktop;

  /*
  A list of attrSets correlating the i3 direction name with a directional key and a vi key
  */
  directionalKeys = [
    { direction = "left"; keys = ["Left" "h"]; }
    { direction = "down"; keys = ["Down" "j"]; }
    { direction = "up"; keys = ["Up" "k"]; }
    { direction = "right"; keys = ["Right" "l"]; }
  ];

  # List of keybindings for workspaces
  workspaceKeys = lib.usefulList.productOfStrings "+" { 
    lis1 = ["" "Shift"]; 
    lis2 = ["1" "2" "3" "4" "5" "6" "7" "8" "9" "0"]; 
  };

  generateWorkspace = num: {name = toString num;};

  mkKeyOption = default: description: lib.mkOption {
    type = types.str;
    inherit default;
    inherit description;
  };
in
{
  imports = [../programs/i3status-rust.nix];

  options.home.desktop = with lib; {
    fonts = mkOption {
      type = types.listOf types.str;
      default = ["monospace 10" "FontAwesome 12"];
      description = "List of fonts to use for text.";
    };

    keys = mkOption {
      type = types.submodule {
        options = {
          commandModifier = mkKeyOption "Mod4" "The modifier key that prefaces all i3 commands.";
          moveModifier = mkKeyOption "Ctrl" "The modifier to use to specify movement commands.";

          terminal = mkKeyOption "Return" "The keybinding for launching the terminal.";
          kill = mkKeyOption "Shift+Escape" "The keybinding for closing an application.";

          rofiPrimary = mkKeyOption "space" "The keybinding for launching rofi in run mode with all the modi.";
          rofiCalc = mkKeyOption "c" "The keybinding for launching rofi in calc mode.";
          rofiEmoji = mkKeyOption "x" "The keybinding for launching rofi in emoji mode.";
          rofiWindow = mkKeyOption "n" "The keybinding for launching rofi in window-switcher mode.";

          focusParent = mkKeyOption "a" "The keybinding for moving focus to the parent container.";

          resize = mkKeyOption "r" "The keybinding for switching to resize mode.";

          splitHorizontal = mkKeyOption "h" "The keybinding for changing the focused container into a horizontal split container.";
          splitVertical = mkKeyOption "v" "The keybinding for changing the focused container into a vertical split container.";
          
          fullscreen = mkKeyOption "f" "The keybinding for toggling fullscreen on the current container.";

          layoutStacking = mkKeyOption "s" "The keybinding for switching the layout mode to stacking.";
          layoutTabbed = mkKeyOption "w" "The keybinding for switching the layout mode to tabbed.";
          layoutSplit = mkKeyOption "e" "The keybinding for toggling the layout mode to split.";

          floating = mkKeyOption "Shift+f" "The keybinding for toggling floating mode on a window.";
          focusToggle = mkKeyOption "Alt+space" "The keybinding for toggling focus mode between floating and tiling windows.";

          reload = mkKeyOption "Shift+c" "The keybinding for reloading the i3 config.";
          restart = mkKeyOption "Shift+r" "The keybinding for restarting i3.";
          exit = mkKeyOption "Shift+e" "The keybinding for exiting i3.";
        }
      };
    };

    terminal = mkOption {
      type = types.str;
      default = "urxvt";
      description = "The terminal program to use when launching a terminal.";
    };

    workspaces = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
          };
          assigns = mkOption {
            type = types.listOf types.attrsOf types.str;
            default = [];
          };
        };
      });
      default = let 
        defaultNamedWorkspaces = [
          {
            name = "1: web";
            assigns = [{ class = "^Firefox$"; }];
          }
        ];
      in
      usefulList.fillList generateWorkspace 20 defaultNamedWorkspaces;
    };
  };

  config = {
    programs.i3status-rust = {
      enable = true;
      bars = {
        default = {
          icons = "awesome";
          theme = "slick";
          blocks = [
            {
              block = "cpu";
              interval = 3;
            }
            {
              block = "sound";
            }
            {
              block = "bluetooth";
              mac = "CC:98:8B:57:17:1C";
            }
            {
              block = "networkmanager";
              ap_format = "{ssid.10} {strength}%";
            }
            {
              block = "battery";
              driver = "upower";
            }
            {
              block = "time";
              format = "%R %a %b %d, %Y";
            }
          ];
        };
      };
    };

    # Rofi (program launcher) config
    programs.rofi = {
      enable = true;
      package =
        pkgs.rofi.override { plugins = [ pkgs.rofi-calc pkgs.rofi-emoji ]; };
    };

    xsession.windowManager.i3 = {
      enable = true;
      config = {
        bars = [
          {
            position = "top";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";

            fonts = cfg.fonts;
          }
        ];

        keybindings = 
        let
          keys = cfg.keys;
          modifier = cfg.keys.commandModifier;

          # Generates an attrset where each key is (prefix + keys) and assigned to (command + direction).  
          makeDirectionalKeybindings = prefix: command: {direction, keys}:
            fold mergeAttrs {} (map (k: { "${prefix}+${k}" = "${command} ${direction}";}) keys);

          # Applies makeDirectionalKeybindings over dirKeysList and merges the resulting attribute lists
          makeAllDirectionalKeybindings = prefix: command: dirKeysList:
            fold mergeAttrs {} (map (makeDirectionalKeybindings prefix command) dirKeysList);

          makeZipKeybindings = prefix: command: params: keys: 
            fold mergeAttrs {} (zipListsWith (param: key: {"${prefix}+${key}" = "${command} ${param}";}) params keys);

          workspaceNames = map (getAttr "name") cfg.workspaces; 

          # Keybindings
          moveFocus = makeAllDirectionalKeybindings modifier "focus" directionalKeys;
          moveContainer = makeAllDirectionalKeybindings "${modifier}+Shift" "move" directionalKeys;
          moveContainerOutput = makeAllDirectionalKeybindings "${modifier}+Ctrl" "move container to output" directionalKeys;
          moveWorkspaceOutput = makeAllDirectionalKeybindings "${modifier}+Ctrl+Shift" "move workspace to output" directionalKeys;
          changeWorkspace = makeZipKeybindings "${modifier}" "workspace" workspaceNames workspaceKeys; 
          moveWorkspace = makeZipKeybindings "${modifier}+Ctrl" "move workspace" workspaceNames workspaceKeys;
        in 
        moveFocus //
        moveContainer //
        moveContainerOutput //
        moveWorkspaceOutput //
        changeWorkspace //
        moveWorkspace //
        {
          "${modifier}+${keys.terminal}" = "exec ${cfg.terminal}"; 
          "${modifier}+${keys.kill}" = "kill";

          "${modifier}+${keys.rofiPrimary}" = "exec rofi -show run";
          "${modifier}+${keys.rofiCalc}" = "exec rofi -show calc -modi calc";
          "${modifier}+${keys.rofiEmoji}" = "exec rofi -show emoji -modi emoji";
          "${modifier}+${keys.rofiWindow}" = "exec rofi -show window -modi window";
          
          "${modifier}+${keys.focusParent}" = "focus parent";

          "${modifier}+${keys.resize}" = "mode resize";
          
          "${modifier}+${keys.splitHorizontal}" = "split h";
          "${modifier}+${keys.splitVertical}" = "split v";

          "${modifier}+${keys.fullscreen}" = "fullscreen toggle";

          "${modifier}+${keys.layoutStacking}" = "layout stacking";
          "${modifier}+${keys.layoutTabbed}" = "layout tabbed";
          "${modifier}+${keys.layoutSplit}" = "layout split";

          "${modifier}+${keys.floating}" = "floating toggle";
          "${modifier}+${keys.focusToggle}" = "focus mode_toggle";

          "${modifier}+${keys.reload}" = "reload";
          "${modifier}+${keys.restart}" = "restart";
          "${modifier}+${keys.exit}" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
        };

        fonts = cfg.fonts;
        modifier = cfg.commandModifier; 
      };
    };
  };
}
