{
  # FIXME: uncomment the next line if you want to reference your GitHub/GitLab access tokens and other secrets
  secrets,
  pkgs,
  username,
  nix-index-database,
  ...
}: let
  unstable-packages = with pkgs.unstable; [
    # FIXME: select your core binaries that you always want on the bleeding-edge
    bat
    bottom
    coreutils
    curl
    du-dust
    fd
    findutils
    fx
    git
    git-crypt
    htop
    jq
    killall
    mosh
    procs
    ripgrep
    sd
    tmux
    tree
    unzip
    vim
    wget
    zip
  ];

  stable-packages = with pkgs; [
    firefox
    # FIXME: you can add plugins, change keymaps etc using (jeezyvim.nixvimExtend {})
    # https://github.com/LGUG2Z/JeezyVim#extending
    jeezyvim

    # key tools
    gh # for bootstrapping
    just

    # core languages
    rustup

    # rust stuff
    cargo-cache
    cargo-expand

    # local dev stuf
    mkcert
    httpie

    # treesitter
    tree-sitter

    # language servers
    nodePackages.vscode-langservers-extracted # html, css, json, eslint
    nodePackages.yaml-language-server
    nil # nix

    # formatters and linters
    alejandra # nix
    deadnix # nix
    nodePackages.prettier
    shellcheck
    shfmt
    statix # nix
    ibm-plex
    cmake
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];

  emacsRepo = "https://github.com/Doomwhite/emacs";
  emacsBranch = "wsl";
  emacsDir = ".emacs.d";
in {
  imports = [
    nix-index-database.hmModules.nix-index
  ];

  home.stateVersion = "22.11";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables.EDITOR = "nvim";
    # FIXME: set your preferred $SHELL
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/fish";
  };

  home.packages =
    stable-packages
    ++ unstable-packages
    ++
    # FIXME: you can add anything else that doesn't fit into the above two lists in here
    [
      # pkgs.some-package
      # pkgs.unstable.some-other-package
    ];

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index.enableFishIntegration = true;
    nix-index-database.comma.enable = true;

    # FIXME: disable this if you don't want to use the starship prompt
    starship.enable = true;
    starship.settings = {
      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = false;
      git_branch.style = "242";
      directory.style = "blue";
      directory.truncate_to_repo = false;
      directory.truncation_length = 8;
      python.disabled = true;
      ruby.disabled = true;
      hostname.ssh_only = false;
      hostname.style = "bold green";
    };

    # FIXME: disable whatever you don't want
    fzf.enable = true;
    fzf.enableFishIntegration = true;
    lsd.enable = true;
    lsd.enableAliases = true;
    zoxide.enable = true;
    zoxide.enableFishIntegration = true;
    zoxide.options = ["--cmd cd"];
    broot.enable = true;
    broot.enableFishIntegration = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    git = {
      enable = true;
      package = pkgs.unstable.git;
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      userEmail = "doomwhitex@gmail.com";
      userName = "Doomwhite";
      extraConfig = {
        url = {
          "https://oauth2:${secrets.github_token}@github.com" = {
            insteadOf = "https://github.com";
          };
        };
        core = {
          longspaths = true;
          preloadindex = true;
          fscache = true;
          defaultbranch = "main";
        };
        fetch = {
          prune = true;
        };
        worktree = {
          guessRemote = true;
        };
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge = {
          conflictstyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
        safe = {
          directory = [ "~/configuration" "~/${emacsDir}" ];
        };
        alias = {
          br = "branch";
          bra = "branch -a";
          brl = "branch -l";
          brr = "branch -r";
          cga = "config --get-regexp alias";
          cg = "config";
          cgg = "config --global -e";
          cgl = "config --local -e";
          cm = "commit";
          cmad = "commit --amend";
          cmadam = "commit --amend -a -m";
          cmadan = "commit --amend -a --no-edit";
          cmadm = "commit --amend -m";
          cmadn = "commit --amend --no-edit";
          cmadpm = "commit --amend -p -m";
          cmadpn = "commit --amend -p --no-edit";
          cmam = "commit -a -m";
          cmm = "commit -m";
          cmp = "commit -p";
          cmpm = "commit -p -m";
          co = "checkout";
          ps = "push";
          psf = "push --force";
          psu = "push -u";
          psup = "!f() { \
            current_branch=$(git rev-parse --abbrev-ref HEAD); \
                remote_branch=\"$current_branch\"; \
                if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then \
                    remote_branch=\"--set-upstream origin $current_branch\"; \
                fi; \
                git push $remote_branch; \
          }; f";
          rao = "remote add origin";
          rb = "rebase";
          rba = "rebase --abort";
          rbc = "rebase --continue";
          st = "status";
          sm = "submodule";
          sma = "submodule add";
          smf = "submodule foreach --recursive";
          sw = "switch";
          swd = "switch dev";
          swm = "switch master";
          up = "!git fetch && git status";
          uppl = "!git up && git pull";
          wt = "worktree";
          wta = "worktree add";
          wtl = "worktree list";
          wtr = "worktree remove";
          wtatb = "!f() { git worktree add --track -b $1 $1 origin/$2; }; f";
          wtab = "!f() { git worktree add -b $1 $1 $2; }; f";
          lsw = "switch -";
        };
      };
    };

    fish = {
      enable = true;
      # run 'scoop install win32yank' on Windows, then add this line with your Windows username to the bottom of interactiveShellInit
      # fish_add_path --append /mnt/c/Users/<Your Windows Username>/scoop/apps/win32yank/0.1.1
      interactiveShellInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

        ${pkgs.lib.strings.fileContents (pkgs.fetchFromGitHub {
            owner = "rebelot";
            repo = "kanagawa.nvim";
            rev = "de7fb5f5de25ab45ec6039e33c80aeecc891dd92";
            sha256 = "sha256-f/CUR0vhMJ1sZgztmVTPvmsAgp0kjFov843Mabdzvqo=";
          }
          + "/extras/kanagawa.fish")}

        set -U fish_greeting
        fish_add_path --append ~/.local/bin
        set -gx PATH $HOME/.local/bin $PATH
      '';
      functions = {
        refresh = "source $HOME/.config/fish/config.fish";
        take = ''mkdir -p -- "$1" && cd -- "$1"'';
        ttake = "cd $(mktemp -d)";
        show_path = "echo $PATH | tr ' ' '\n'";
        posix-source = ''
          for i in (cat $argv)
            set arr (echo $i |tr = \n)
            set -gx $arr[1] $arr[2]
          end
        '';
      };
      shellAbbrs =
        {
          gc = "nix-collect-garbage --delete-old";
        }
        # navigation shortcuts
        // {
          ".." = "cd ..";
          "..." = "cd ../../";
          "...." = "cd ../../../";
          "....." = "cd ../../../../";
        }
        # git shortcuts
        // {
          gapa = "git add --patch";
          grpa = "git reset --patch";
          gst = "git status";
          gdh = "git diff HEAD";
          gp = "git push";
          gph = "git push -u origin HEAD";
          gco = "git checkout";
          gcob = "git checkout -b";
          gcm = "git checkout master";
          gcd = "git checkout develop";
          gsp = "git stash push -m";
          gsa = "git stash apply stash^{/";
          gsl = "git stash list";
        };
      shellAliases = {
        mxc = "emacsclient -c -n";
        pbcopy = "/mnt/c/Windows/System32/clip.exe";
        pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
        explorer = "/mnt/c/Windows/explorer.exe";
      };
      plugins = [
        {
          inherit (pkgs.fishPlugins.autopair) src;
          name = "autopair";
        }
        {
          inherit (pkgs.fishPlugins.done) src;
          name = "done";
        }
        {
          inherit (pkgs.fishPlugins.sponge) src;
          name = "sponge";
        }
      ];
    };

    emacs = {
      enable = true;
      package = pkgs.emacs;
    };
  };

  systemd.user.services."clone_emacs_repo" = {
    Unit = {
      Description = "Clone Doomwhite's emacs repository if not already present";
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "emacs_repo" ''
        if [ ! -d ~/${emacsDir} ]; then
          ${pkgs.git}/bin/git clone -b ${emacsBranch} ${emacsRepo} ~/${emacsDir}
        fi
      ''}";
    };
  };
}
