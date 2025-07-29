{ config, pkgs, lib, ... }:

let

  repos = {
    exec = {
      src = "https://github.com/thedynamiclinker/exec";
      dst = "${homeDir}/Desktop/repos/exec";
    };
    personal = {
      src = "https://github.com/rskottap/personal";
      dst = "${homeDir}/Desktop/repos/personal";
    };
    secret = {
      src = "git@github.com:rskottap/secret.git";
      dst = "${homeDir}/Desktop/repos/secret";
    };
    shortcuts = {
      src = "https://github.com/rskottap/shortcuts";
      dst = "${homeDir}/Desktop/repos/shortcuts";
    };
    nixos = {
      src = "https://github.com/rskottap/nixos";
      dst = "${homeDir}/Desktop/repos/nixos";
    };
  };

  desktopDirs = [
    "${homeDir}/Desktop/screenshots"
    "${homeDir}/Desktop/obsidian"
  ];
in {

  home.stateVersion = "25.05";

  ### =====================
  ### Clone Repos & Create Dirs
  ### =====================
  home.activation.setupEnvironment = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "🔁 Cloning personal repos and setting up directories..."

    mkdir -pv ${homeDir}/Desktop/repos

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: r:
      ''
        if [ ! -d "${r.dst}" ]; then
          echo "Cloning ${name}..."
          git clone ${r.src} "${r.dst}" || echo "❌ Failed to clone ${name}"
        fi
      ''
    ) repos)}

    mkdir -pv ${lib.concatStringsSep " " desktopDirs}
  '';

  ### =====================
  ### Dotfiles
  ### =====================
  home.file.".vimrc".source = "${repos.exec.dst}/etc/vimrc";
  home.file.".pypirc".source = "${repos.secret.dst}/etc/pypirc";
  home.file.".gitconfig".source = "${repos.personal.dst}/etc/gitconfig";
  home.file.".profile".source = "${repos.personal.dst}/etc/profile";

  ### =====================
  ### Bash
  ### =====================
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source "${repos.exec.dst}/etc/bashrc"
      source "${repos.personal.dst}/etc/bashrc"
      source "${repos.secret.dst}/etc/bashrc"

      for f in "${repos.personal.dst}"/etc/bash_completion.d/*; do
        [ -f "$f" ] && source "$f"
      done
    '';
  };

  ### =====================
  ### Minimal packages required to do this
  ### =====================

  home.packages = with pkgs; [
    git
    dconf
    dconf-editor
    google-chrome
  ];

  ### =====================
  ### Cinnamon / GTK / Themes (Optional, ignored on non-Cinnamon)
  ### =====================
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

  ### =====================
  ### Shortcut Setup Scripts
  ### =====================
  home.activation.setupShortcuts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "⚙️ Running shortcut configuration scripts..."
    bash "${repos.shortcuts.dst}/cinnamon/custom-shortcuts-setup" || true
    bash "${repos.shortcuts.dst}/vscode/vscode-shortcuts-setup" || true
  '';

  ### =====================
  ### Symlinks for home.nix and configuration.nix
  ### =====================
  home.activation.setupNixosSymlinks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d /etc/nixos ]; then
      sudo ln -svf "${repos.nixos.dst}/configuration.nix" /etc/nixos/configuration.nix
    fi

    mkdir -p ~/.config/home-manager
    ln -svf "${repos.nixos.dst}/home.nix" ~/.config/home-manager/home.nix
  '';
}
