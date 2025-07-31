{ config, pkgs, lib, ... }:

let

  user = "ramya";
  dst = "${config.home.homeDirectory}/Desktop/repos";

  exec = {
    name = "exec";
    src = "https://github.com/thedynamiclinker/exec";
    dst = "${dst}/exec";
  };
  personal = {
    name = "personal";
    src = "https://github.com/rskottap/personal";
    dst = "${dst}/personal";
  };
  secret = {
    name = "secret";
    src = "https://github.com/rskottap/secret";
    dst = "${dst}/secret";
  };
  shortcuts = {
    name = "shortcuts";
    src = "https://github.com/rskottap/shortcuts";
    dst = "${dst}/shortcuts";
  };
  nixos = {
    name = "nixos";
    src = "https://github.com/rskottap/nixos";
    dst = "${dst}/nixos";
  };

  # List of all repos for looping
  repos = [ exec personal secret shortcuts nixos ];

  desktopDirs = [
    "${config.home.homeDirectory}/Desktop/screenshots"
    "${config.home.homeDirectory}/Desktop/obsidian"
    "${config.home.homeDirectory}/Desktop/repos"
  ];

in {

  home.username = user;
  home.homeDirectory = lib.mkDefault "/home/${user}";

  home.stateVersion = "25.05";

  home.sessionVariables = {
    EDITOR = "vim";
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    git
    openssh
    dconf
    dconf-editor
  ];

  home.activation.cloneRepos = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''
    mkdir -pv ${lib.concatStringsSep " " desktopDirs}

    export PATH="${pkgs.git}/bin:$PATH"
    export PATH="${pkgs.openssh}/bin/:$PATH"

    ${lib.concatMapStringsSep "\n" (repo: ''
      if [ ! -d "${repo.dst}" ]; then
        git clone "${repo.src}" "${repo.dst}"
        echo "✅  Cloned ${repo.name}."
      fi
    '') repos}
  '';

  home.activation.setupDotfiles = lib.hm.dag.entryAfter ["cloneRepos"] ''
    ln -svf "${exec.dst}/etc/vimrc" ~/.vimrc
    ln -svf "${secret.dst}/etc/pypirc" ~/.pypirc
    ln -svf "${personal.dst}/etc/gitconfig" ~/.gitconfig
  '';

  home.file = {

    # ~/.icons
    ".local/share/icons/start.png".source = ./icons/start.png;
  };

  home.activation.setupShortcuts = lib.hm.dag.entryAfter ["setupDotfiles"] ''
    export PATH="${pkgs.dconf}/bin:$PATH"

    if [ -f "${shortcuts.dst}/cinnamon/custom-shortcuts-setup" ]; then
      cd "${shortcuts.dst}/cinnamon/" && bash "./custom-shortcuts-setup"
    fi
    
    if [ -f "${shortcuts.dst}/vscode/vscode-shortcuts-setup" ]; then
      cd "${shortcuts.dst}/vscode/" && bash "./vscode-shortcuts-setup"
    fi
    echo "✅ Setup Shortcuts."
  '';

  # NOTE: On NIXOS simply rm /etc/nixos and symlink it to your own nixos repo (wherever it lives)
  home.activation.setupNixosSymlinks = lib.hm.dag.entryAfter ["setupShortcuts"] ''
    if [ -d /etc/nixos ] && [ -f "${nixos.dst}/configuration.nix" ]; then
      sudo rm -rf /etc/nixos
      sudo ln -svf ${nixos.dst} /etc/nixos
      echo "✅ Symlinked /etc/nixos"
    fi
  '';

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source "${exec.dst}/etc/bashrc"
      source "${personal.dst}/etc/bashrc"
      source "${secret.dst}/etc/bashrc"
    '';
  };

  # PATH for interactive shells
  home.sessionVariables.PATH = "${exec.dst}/bin:${personal.dst}/bin:${secret.dst}/bin:$PATH";

  # PATH for login shells
  home.sessionPath = [
    "${exec.dst}/bin"
    "${personal.dst}/bin"
    "${secret.dst}/bin"
  ];

  # ~/.config/gh
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

   # gtk theme for cinnamon
  gtk = {
    enable = true;
    theme = {
      name = "Mint-Y-Dark-Blue";
      package = pkgs.mint-themes;
    };
    iconTheme = {
      name = "Kora-light";
      package = pkgs.kora-icon-theme;
    };
  };
  # Let Home Manager install and manage itself.
  #programs.home-manager.enable = true;

}
