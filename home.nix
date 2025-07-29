{ config, pkgs, lib, ... }:

let
  user = "ramya";
  
  repos = {
    exec = {
      src = "https://github.com/thedynamiclinker/exec";
      dst = "${config.home.homeDirectory}/Desktop/repos/exec";
    };
    personal = {
      src = "https://github.com/rskottap/personal";
      dst = "${config.home.homeDirectory}/Desktop/repos/personal";
    };
    secret = {
      src = "https://github.com/rskottap/secret";
      dst = "${config.home.homeDirectory}/Desktop/repos/secret";
    };
    shortcuts = {
      src = "https://github.com/rskottap/shortcuts";
      dst = "${config.home.homeDirectory}/Desktop/repos/shortcuts";
    };
    nixos = {
      src = "https://github.com/rskottap/nixos";
      dst = "${config.home.homeDirectory}/Desktop/repos/nixos";
    };
  };

  desktopDirs = [
    "${config.home.homeDirectory}/Desktop/screenshots"
    "${config.home.homeDirectory}/Desktop/obsidian"
    "${config.home.homeDirectory}/Desktop/repos"
  ];

in {

  home.username = user;
  home.homeDirectory = lib.mkDefault "/home/${user}";
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    git
    openssh
    dconf
    dconf-editor
    home-manager
  ];

  home.activation.cloneRepos = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''
    mkdir -pv ${lib.concatStringsSep " " desktopDirs}

    export PATH="${pkgs.git}/bin:$PATH"
    export PATH="${pkgs.openssh}/bin/:$PATH"

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: r:
      ''
        if [ ! -d "${r.dst}" ]; then
          git clone "${r.src}" "${r.dst}"
          echo "✅  Cloned ${name}."
        fi
      ''
    ) repos)}
  '';

  home.activation.setupDotfiles = lib.hm.dag.entryAfter ["cloneRepos"] ''
    ln -svf "${repos.exec.dst}/etc/vimrc" ~/.vimrc
    ln -svf "${repos.secret.dst}/etc/pypirc" ~/.pypirc
    ln -svf "${repos.personal.dst}/etc/gitconfig" ~/.gitconfig
  '';

  home.activation.setupShortcuts = lib.hm.dag.entryAfter ["setupDotfiles"] ''
    export PATH="${pkgs.dconf}/bin:$PATH"

    if [ -f "${repos.shortcuts.dst}/cinnamon/custom-shortcuts-setup" ]; then
      cd "${repos.shortcuts.dst}/cinnamon/" && bash "./custom-shortcuts-setup"
    fi
    
    if [ -f "${repos.shortcuts.dst}/vscode/vscode-shortcuts-setup" ]; then
      cd "${repos.shortcuts.dst}/vscode/" && bash "./vscode-shortcuts-setup"
    fi
    echo "✅ Setup Shortcuts."
  '';

  home.activation.setupNixosSymlinks = lib.hm.dag.entryAfter ["setupShortcuts"] ''
    if [ -d /etc/nixos ] && [ -f "${repos.nixos.dst}/configuration.nix" ]; then
      sudo ln -svf "${repos.nixos.dst}/configuration.nix" /etc/nixos/configuration.nix
      echo "✅ Symlinked NixOS configuration.nix."
    fi
  '';

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      for config_file in \
        "${repos.exec.dst}/etc/bashrc" \
        "${repos.personal.dst}/etc/bashrc" \
        "${repos.secret.dst}/etc/bashrc"; do
        [ -f "$config_file" ] && source "$config_file"
      done

      if [ -d "${repos.personal.dst}/etc/bash_completion.d" ]; then
        for f in "${repos.personal.dst}"/etc/bash_completion.d/*; do
          [ -f "$f" ] && source "$f"
        done
      fi
    '';
  };

  # ~/.config/gh
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  dconf.settings = {
    "org/cinnamon/desktop/interface" = {
      gtk-theme = "CBlack";
      icon-theme = "kora-light";
    };
    "org/gnome/desktop/interface" = {
      gtk-theme = "CBlack";
      icon-theme = "kora-light";
    };
  };

}
