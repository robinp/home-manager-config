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

  home.stateVersion = "21.11";
  home.username = "ron";
  home.homeDirectory= "/home/ron";

  home.keyboard = {
    layout = "us";
    variant = "dvp";
    options = [ "compose:ralt" ];
  };

  home.sessionVariables = {
    EDITOR = "vim";
    TERM = "xterm-256color";
    TERMINAL = "urxvt";
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

            vim-pencil

            vim-nix

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
      myvim
      emacs fd haskell-language-server
      ctags
      python3

      fira-code  # Note: fira-code supports powerline (/airline)
      source-serif-pro
      source-sans-pro

      dmenu  # For i3

      urxvt_font_size

      chromium dig mosh

      discord teamviewer

      evince
      mplayer sox zoom-us
      ranger mc
      freemind
      timewarrior

      gimp inkscape
      scrot imagemagick

      thefuck fzf tree ripgrep
      zip unzip
      mupdf
      htop multitail ncdu
      curl wget nmap
      xscreensaver
      youtube-dl
      wireshark
      _1password
      _1password-gui

      # qt5.full  # why did we need this in the first place?
      sigil calibre
      xclip
      # xdotool

      taskjuggler

      docker docker-compose
    ];

  home.file.".bashrc".text = ''
      eval $(thefuck --alias)
      alias d="dict --host localhost"
      alias gs="git status"
      alias gsi="git status --ignored"
      alias gsip="git status --ignored --porcelain | grep '!!'"
      alias ty="task +py"
      export LS_COLORS="di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
  '';

  home.file.taskhook = {
    source = "${patchedTimewarriorHook}";
    target = ".local/share/task/hooks/on-modify.timewarrior";
    executable = true;
  };

  programs.autorandr = {
    enable = true;
		profiles = with
			{ EDID_LVDS_1 = "00ffffffffffff0030e4d3020000000000150103801c1078ea10a59658578f2820505400000001010101010101010101010101010101381d56d45000163030202500159c1000001b000000000000000000000000000000000000000000fe004c4720446973706c61790a2020000000fe004c503132355748322d544c423100f";
        EDID_DELL = "00ffffffffffff0010ac98a14c4152300b200104b53c22783b5095a8544ea5260f5054a54b00714f8180a9c0a940d1c0e100010101014dd000a0f0703e803020350055502100001a000000ff0033315a444d34330a2020202020000000fc0044454c4c20533237323151530a000000fd00283c89893c010a20202020202001c2020321f15461010203040506071011121415161f20215d5e5f2309070783010000565e00a0a0a029503020350055502100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fc";
				CONFIG_DELL = {
					enable = true;
					crtc = 1;
					position = "0x0";
					mode = "3840x2160";
					rate = "30.00";
					gamma = "1.0:0.769:0.556";
				};
			  CONFIG_INTERNAL = {
					enable = true;
					crtc = 0;
					position = "0x0";
					mode = "1366x768";
					rate = "60.00";
					gamma = "1.0:0.769:0.556";
				};
      }; {
       "internal+del" = {
				fingerprint = {
					"D-P1" = EDID_DELL;
					"LVDS-1" = EDID_LVDS_1;
				};
				config = {
					"LVDS-1" = CONFIG_INTERNAL // {
						position = "0x2160";  # below
						transform = [[1.500000 0.000000 0.000000] [0.000000 1.500000 0.000000] [0.000000 0.000000 1.000000]];
					};
					"DP-1" = CONFIG_DELL // {
						primary = true;
					};
				};
			};

			"del" = {
				fingerprint = {
					"DP-1" = EDID_DELL;
				};
				config = {
					"LVDS-1".enable = false;
					"DP-1" = CONFIG_DELL // {
						primary = true;
					};
				};
			};
		};
    hooks = {
			postswitch = {
				"notify-i3" = "${pkgs.i3}/bin/i3-msg restart";
				"change-dpi" = ''
					 case "$AUTORANDR_CURRENT_PROFILE" in
						 default)
							 DPI=120
							 ;;
						 dell)
							 DPI=200
							 ;;
						 *)
							 echo "Unknown profile: $AUTORANDR_CURRENT_PROFILE"
							 exit 1
					 esac

					 echo "Xft.dpi: $DPI" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
				'';
			};
    };
  };

  programs.vscode = {
    enable = true;
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

  xresources.properties = {
    "URxvt.perl-ext-common" = "resize-font";
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

  services.dropbox = {
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
