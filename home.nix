{ config, pkgs, lib, ... }:

{
  imports = [ ./loose_configs ./theme.nix ./modules/desktop-environment.nix ];

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

  home.packages = with pkgs; let
   
    fonts = [
      dejavu_fonts
      liberation_ttf
      noto-fonts
      (nerdfonts.override { fonts = ["CascadiaCode" "FiraCode" "Hack" "DroidSansMono"]; })
    ];

    dev-tools = [
      nodejs-14_x
      (import (fetchTarball "https://github.com/nix-community/rnix-lsp/archive/master.tar.gz"))
    ];

    gui = let

      # Gui apps
      gui-core = [
        arandr
        breeze-icons
        breeze-qt5
        glxinfo
        gnome3.adwaita-icon-theme
        #pkgs-unstable.nur.repos.nexromancers.hacksaw
        hicolor-icon-theme
        #pkgs-unstable.nur.repos.nexromancers.shotgun
        xsel
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
        scummvm
        steam
        steam.run
        stepmania
        # pkgs.lutris
      ];

      gui-media = [
        vlc
      ];
      
      gui-misc = [
        discord
      ];

      gui-tools = [
       #`` pkgs.vscode
      ];
    in lib.concatLists [ gui-core gui-games gui-media gui-misc gui-tools ];
  
  misc = [
    youtube-dl
  ];

  in lib.concatLists [ fonts dev-tools gui misc ];

  fonts.fontconfig.enable = true;

  home.theme = {
    enable = true;
    colors = import ./themes/embark.nix;
    setXresources = true;
  };

  home.desktop = {
    fonts = ["Caskaydia Cove Nerd Font 10"];
  };

  programs.neovim = {
    enable = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
      airline
      coc-nvim
      vim-nix
      nerdtree
      vim-devicons
    ];
    extraConfig = ''
      set number
      set tabstop=4
      set shiftwidth=4
      set noequalalways
      set mouse=nvc

      augroup ProjectDrawer
        autocmd!
        autocmd VimEnter * NERDTree
      augroup END
    '';
  };

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

  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };

  services.lorri.enable = true;
  services.flameshot.enable = true;
}
