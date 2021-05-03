{ config, pkgs, lib, ... }:

{
  imports = [ ./theme.nix ./home-window-manager.nix ];

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

}
