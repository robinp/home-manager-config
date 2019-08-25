{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      config = {
        keybindings = {};  # Appended from i3.config below.
      };
      extraConfig = builtins.readFile ./i3.config;
    };
  };

  home.keyboard = {
    layout = "us";
    variant = "dvp";
    options = [ "compose:ralt" ];
  };

  home.sessionVariables = {
    EDITOR = "vim";
    TERM = "xterm-256color";
  };

  home.packages =
    with pkgs;
    with rec {
      customPlugins = {
        ghcid-quickfix = vimUtils.buildVimPlugin {
          name = "ghcid-quickfix";
          src = fetchFromGitHub {
            owner = "aiya000";
            repo = "vim-ghcid-quickfix";
            rev = "07c9b377f1dfadb3e90e42011e7c006e3713c9e1";
            sha256 = "0askza9v60qvm7gjkcd8rg5v89nfy2fnlwbk7qd2b5dz83g3lqjj";
          };
        };
        vim-wordy = vimUtils.buildVimPlugin {
          name = "vim-wordy";
          src = fetchFromGitHub {
            #owner = "reedes";
            owner = "robinp";  # until PR is merged
            repo = "vim-wordy";
            rev = "4e097f5552731229cbda3ed7b55004b56c2b84f4";
            sha256 = "1c235faydn95s4nwa4in6ag58r00nclqxncrlvby2kcpm8l2r0kz";
          };
        };
        tmuxline = vimUtils.buildVimPlugin {
          name = "tmuxline";
          src = fetchFromGitHub {
            owner = "edkolev";
            repo = "tmuxline.vim";
            rev = "6386ac13a2f6360cf3cf34f22772a82e7e45843e";
            sha256 = "0lqi7rvafwamdv1gn855nw24z711yj6kmhagw023pmzlrcjw07w9";
          };
        };
      };
      myvim = vim_configurable.customize {
        name = "vim";
        vimrcConfig.packages.myVimPackage = with vimPlugins; {
          start = [
            sensible
            vim-unimpaired  # ?

            # To highlight eol-spaces etc.
            vim-better-whitespace

            bufexplorer
            gitgutter

            molokai
            airline vim-airline-themes

            # Haskell
            customPlugins.ghcid-quickfix

            # Writing

            # :Wordy weak
            # :NoWordy
            # :NextWordy
            # ]s [s to go through problematic
            customPlugins.vim-wordy

            customPlugins.tmuxline

            fzf-vim fzfWrapper

            # TODO(robinp):
            # fzf tabular repeat supertab easymotion tmux-navigator fugitive surround tmuxline
          ];
        };
        vimrcConfig.customRC = ''
          set nocompatible
          set expandtab
          set number
          set tabstop=2
          set shiftwidth=2

          set colorcolumn=80

          colorscheme molokai
          let g:airline_powerline_fonts = 1

          let g:wordy_spell_dir = '/home/ron/wordy'
        '';
      };
    };
    [
      brave

      myvim

      fira-code  # Note: fire-code supports powerline (/airline)

      dmenu  # For i3

      scrot imagemagick
      thefuck fzf tree
      htop multitail
      curl wget nmap
      xscreensaver
      youtube-dl
      # xdotool
    ];

  home.file.".bashrc".text = ''
      eval $(thefuck --alias)
  '';

  programs.git = {
    enable = true;
    userName = "Robin Palotai";
    userEmail = "palotai.robin@gmail.com";
    aliases = {
      co = "checkout";
      st = "status";
    };
  };

  programs.urxvt = {
    enable = true;
    extraConfig = {
      background = "black";
      foreground = "white";
    };
    fonts = [
      "xft:Fira Code:size=10"
    ];
    scroll.bar.enable = false;
    shading = 20;
    transparent = true;
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    terminal = "screen-256color";
    extraConfig = ''
      set -g status-bg colour237
      set -g status-bg colour249
    '';
  };

  programs.taskwarrior = {
    enable = true;
  };

  services.redshift = {
    enable = true;
    latitude = "47.49801";
    longitude = "19.03991";
  };

  services.random-background = {
    enable = true;
    imageDirectory = "%h/backgrounds";
    interval = "1h";
  };
}
