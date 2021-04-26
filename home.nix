{ config, pkgs, lib, ... }:

{
  imports = [ ./theme.nix ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "izzylan";
  home.homeDirectory = "/home/izzylan";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";

  home.packages = let
   
    fonts = [
      pkgs.dejavu_fonts
      pkgs.liberation_ttf
      pkgs.noto-fonts
      pkgs.cascadia-code
      (pkgs.nerdfonts.override { fonts = ["CascadiaCode" "FiraCode" "Hack" "DroidSansMono"]; })
    ];

    dev-tools = [
      pkgs.nodejs-14_x
      (import (fetchTarball "https://github.com/nix-community/rnix-lsp/archive/master.tar.gz"))
    ];

    # Gui apps

    gui-core = [
      pkgs.arandr
      pkgs.breeze-icons
      pkgs.breeze-qt5
      pkgs.glxinfo
      pkgs.gnome3.adwaita-icon-theme
      #pkgs-unstable.nur.repos.nexromancers.hacksaw
      pkgs.hicolor-icon-theme
      #pkgs-unstable.nur.repos.nexromancers.shotgun
      #pkgs.nur.repos.bb010g.st-bb010g-unstable
      pkgs.xsel
    ];

    gui-games = let
      steam = pkgs.steam.override {
        # nativeOnly = true;
        extraPkgs = p:
          with p; [
            libpng
            usbutils
            lsb-release
            procps
            dbus_daemon
            libnice
            libcap
            libpng
          ];
      };
    in [
      pkgs.scummvm
      steam
      steam.run
      pkgs.stepmania
      # pkgs.lutris
    ];
    
    gui-misc = [
      pkgs.discord
    ];

    gui-tools = [
     #`` pkgs.vscode
    ];
    
    gui = lib.concatLists [ gui-core gui-games gui-misc gui-tools ];
  
  in lib.concatLists [ fonts dev-tools gui ];

  fonts.fontconfig.enable = true;

  home.theme = {
    enable = true;
    colors = import ./themes/embark.nix;
    setXresources = true;
  };

  # Rofi (program launcher) config
  programs.rofi = {
    enable = true;
    package =
      pkgs.rofi.override { plugins = [ pkgs.rofi-calc pkgs.rofi-emoji ]; };
    pass.enable = true;
  };

  programs.neovim = {
    enable = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
      airline
      coc-nvim
      vim-nix
    ];
  };

  # Config file for coc-nvim plugin
  xdg.configFile."nvim/coc-settings.json".source = ./coc-settings.json;

  programs.urxvt = {
    enable = true;
    fonts = [ "xft:CaskaydiaCove Nerd Font Mono:size=11" ];
  };

  programs.git = {
    enable = true;
    userEmail = "avrisaac555@gmail.com";
    userName = "Izzy Lancaster";
    signing = {
      key = "909FF46310D666DB";
      signByDefault = true;
    };
  };

  xsession = {
    enable = true;
    pointerCursor = {
      name = "Bibata_Classic";
      package = pkgs.bibata-cursors;
    };
    windowManager.i3 = {
      enable = true;
      config = let
        zipToAttrs = lib.zipListsWith (n: v: { ${n} = v; });
        mergeAttrList = lib.foldr lib.mergeAttrs { };
        mergeAttrMap = f: l: mergeAttrList (lib.concatMap f l);

        modifier = "Mod4";
        arrowKeys = [ "Left" "Down" "Up" "Right" ];
        viKeys = [ "h" "j" "k" "l" ];
        workspaceNames = builtins.map toString (lib.range 1 40);
        workspaceKeys = lib.crossLists (m: k: "${m}${k}") [
          [ "" "Ctrl+" "Mod1+" "Ctrl+Mod1+" ]
          [ "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" ]
        ];

        fonts = [ "monospace 10" ];

        dirNames = [ "left" "down" "up" "right" ];
        resizeActions =
          [ "shrink width" "grow height" "shrink height" "grow width" ];
        mode_system =
          "System (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (Shift+s) shutdown";
      in {
        bars = [{
          inherit fonts;
          position = "bottom";
         #  statusCommand =
         #   "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-bottom.toml";
        }];
        inherit fonts;
        startup = [{
          command = "./.screenlayout/desktop.sh";
          notification = false;
        }];
        keybindings = mergeAttrList [
          (mergeAttrMap (ks:
            zipToAttrs (map (k: "${modifier}+${k}") ks)
            (map (d: "focus ${d}") dirNames)) [ viKeys arrowKeys ])
          (mergeAttrMap (ks:
            zipToAttrs (map (k: "${modifier}+Shift+${k}") ks)
            (map (d: "move ${d}") dirNames)) [ viKeys arrowKeys ])
          (mergeAttrMap (ks:
            zipToAttrs (map (k: "${modifier}+Ctrl+${k}") ks)
            (map (d: "move container to output ${d}") dirNames)) [
              viKeys
              arrowKeys
            ])
          (mergeAttrMap (ks:
            zipToAttrs (map (k: "${modifier}+Ctrl+Shift+${k}") ks)
            (map (d: "move workspace to output ${d}") dirNames)) [
              viKeys
              arrowKeys
            ])
          (mergeAttrList (zipToAttrs (map (k: "${modifier}+${k}") workspaceKeys)
            (map (d: "workspace ${d}") workspaceNames)))
          (mergeAttrList
            (zipToAttrs (map (k: "${modifier}+Shift+${k}") workspaceKeys)
              (map (d: "move workspace ${d}") workspaceNames)))
          {
            "${modifier}+Return" = "exec urxvt";
            "${modifier}+Shift+Return" =
              "exec ${pkgs.enlightenment.terminology}/bin/terminology";
            "${modifier}+Shift+q" = "kill";
            "${modifier}+d" = "exec rofi -show run";
            "${modifier}+Shift+d" = "exec rofi -show drun -modi drun";
            "${modifier}+c" = "exec rofi -show calc -modi calc";
            "${modifier}+x" = "exec rofi -show emoji -modi emoji";
            "${modifier}+n" = "exec rofi -show window -modi window";
            "${modifier}+p" = "exec rofi-pass";
            "${modifier}+Shift+s" =
              "exec ${pkgs.rofi-systemd}/bin/rofi-systemd";
            "${modifier}+Ctrl+s" = "exec rofi -show ssh -modi ssh";

            "${modifier}+a" = "focus parent";

            "${modifier}+r" = "mode resize";
            "${modifier}+Pause" = ''mode "${mode_system}"'';

            "${modifier}+g" = "split h";
            "${modifier}+v" = "split v";
            "${modifier}+f" = "fullscreen toggle";

            "${modifier}+s" = "layout stacking";
            "${modifier}+w" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";

            "${modifier}+Shift+space" = "floating toggle";
            "${modifier}+space" = "focus mode_toggle";

            "${modifier}+Shift+c" = "reload";
            "${modifier}+Shift+r" = "restart";
            "${modifier}+Shift+e" =
              "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
            #"${modifier}+Control+q" = "exec bash -c \"i3-nagbar -t warning -m 'do you want to kill this window $(${pkgs.xdotool}/bin/xdotool selectwindow getwindowpid)\"";
            "--release ${modifier}+Ctrl+q" =
              "exec ${pkgs.xorg.xkill}/bin/xkill";
            "--release ${modifier}+Ctrl+Shift+q" = ''
              exec kill -9 $(xdotool getwindowpid "$(xdotool getwindowfocus)" )'';
          }
        ];
        modes = {
          resize = mergeAttrList [
            (mergeAttrMap
              (ks: zipToAttrs ks (map (a: "resize ${a}") resizeActions)) [
                viKeys
                arrowKeys
              ])
            {
              "Escape" = "mode default";
              "Return" = "mode default";
            }
          ];
          "${mode_system}" = let
            lock_command = "i3lock -c 555555";
            act_then_lock =
              (act: "${act} ; exec ${lock_command} ; mode default");
          in {
            "l" = "exec ${lock_command}; mode default";
            "e" = "exec i3-msg exit";
            "s" = act_then_lock "exec systemctl suspend";
            "h" = act_then_lock "exec systemctl hibernate";
            "r" = "exec systemctl reboot";
            "Shift+s" = "exec systemctl poweroff";

            "Return" = "mode default";
            "Escape" = "mode default";
          };
        };
        inherit modifier;
      };
    };
  };
}
