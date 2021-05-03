{pkgs, config, lib, ...}:

with lib;

let
  cfg = config.home.windowManager;

  # Polyfill from nixpkgs master
  cartesianProductOfSets = attrsOfLists:
    lib.foldl' (listOfAttrs: attrName:
      concatMap (attrs:
        map (listValue: attrs // { ${attrName} = listValue; }) attrsOfLists.${attrName}
      ) listOfAttrs
    ) [{}] (attrNames attrsOfLists);

  fillWorkspaceList = workspaceList: amount:
    let 
      mapFn = num: { name = toString num; };
      rangeBegin = (length workspaceList) + 1;
    in
    workspaceList ++ builtins.map mapFn (lib.range rangeBegin amount); 

  /*
  A list of attrSets correlating the i3 direction name with a directional key and a vi key
  */
  directionalKeys = [
    { direction = "left"; keys = ["Left" "h"]; }
    { direction = "down"; keys = ["Down" "j"]; }
    { direction = "up"; keys = ["Up" "k"]; }
    { direction = "right"; keys = ["Right" "l"]; }
  ];

  /*
  Takes the cartesian product of an attribute set of lists of strings, and concats the resulting list of attribute sets of strings with the provided separator to produce a list of strings.

  Example:
    crossStringLists "+" {lis1 = ["a" "b" "c"] lis2 = ["d" "e" "f"]}
    => [
        "a+d"
        "a+e"
        "a+f"
        "b+d"
        "b+e"
        "b+f"
        "c+d"
        "c+e"
        "c+f"
      ]
  */
  crossStringLists = separator: attrsOfLists:
    let
      mapFn = attr: builtins.concatStringsSep separator (builtins.attrValues attr); 
    in
    map mapFn (cartesianProductOfSets attrsOfLists);


  # List of keybindings for workspaces
  workspaceKeys = crossStringLists "+" { 
    lis1 = ["" "Shift"]; 
    lis2 = ["1" "2" "3" "4" "5" "6" "7" "8" "9" "0"]; 
  };
in
{
  imports = [./programs/i3status-rust.nix];

  options.home.windowManager = {
    fonts = mkOption {
      type = types.listOf types.str;
      default = ["monospace 10" "FontAwesome 12"];
      description = "List of fonts to use for text.";
    };

    commandModifier = mkOption {
      type = types.str;
      default = "Mod4";
      description = "The modifier key that prefaces all i3 commands.";
    };

    moveModifier = mkOption {
      type = types.str;
      default = "Ctrl";
      description = "The modifier to combine the with command modifier for movement commands.";
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
      default = fillWorkspaceList [
        {
          name = "1: web";
          assigns = [{ class = "^Firefox$"; }];
        }
      ] 20;
    };
  };

  config = {
    programs.i3status-rust = {
      enable = true;
      bars = {
        default = {
          icons = "awesome5";
          blocks = [
            {
              block = "cpu";
              interval = 3;
            }
            {
              block = "sound";
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
          modifier = cfg.commandModifier;

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
          "${modifier}+Return" = "exec ${cfg.terminal}"; 
          "${modifier}+Shift+Esc" = "kill";
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+r" = "restart";

          "${modifier}+Space" = "exec rofi -show run";
          "${modifier}+c" = "exec rofi -show calc -modi calc";
          "${modifier}+x" = "exec rofi -show emoji -modi emoji";
          "${modifier}+n" = "exec rofi -show window -modi window";
        };

        terminal = cfg.terminal;
        fonts = cfg.fonts;
        modifier = cfg.commandModifier; 
      };
    };
  };
}
