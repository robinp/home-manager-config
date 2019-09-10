{ config, pkgs, ... }:

with {
  patchedTimewarriorHook = pkgs.stdenv.mkDerivation {
    name = "my-timewarrior-hook";
    buildInputs = [ pkgs.python ];
    buildCommand = ''
      cp ${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior $out
      chmod +x $out
      patchShebangs $out
    '';
    unpackPhase = "";
  };
};
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Use the .bashrc contents below rather
  # programs.bash.shellAliases = { };

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

            undotree
            bufexplorer
            gitgutter
            tagbar

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
      ctags

      fira-code  # Note: fira-code supports powerline (/airline)

      dmenu  # For i3

      evince
      mplayer sox zoom-us
      ranger mc
      freemind
      timewarrior

      scrot imagemagick
      thefuck fzf tree ripgrep
      zip unzip
      mupdf
      htop multitail ncdu
      curl wget nmap
      xscreensaver
      youtube-dl

      qt5.full sigil calibre
      # xdotool
    ];

  home.file.".bashrc".text = ''
      eval $(thefuck --alias)
      alias d="dict --host localhost"
      alias gs="git status"
      alias gsi="git status --ignored"
      alias gsip="git status --ignored --porcelain | grep '!!'"

  '';

  home.file.taskhook = {
    source = "${patchedTimewarriorHook}";
    target = ".local/share/task/hooks/on-modify.timewarrior";
    executable = true;
  };

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

  services.xscreensaver = {
    enable = true;
  };
}
