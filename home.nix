{ config, pkgs, lib, ... }:

let
  user = "ramya";
  
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
    home-manager
  ];

  home.activation.cloneRepos = lib.hm.dag.entryAfter ["writeBoundary" "installPackages"] ''
    mkdir -pv ${lib.concatStringsSep " " desktopDirs}

    export PATH="${pkgs.git}/bin:$PATH"
    export PATH="${pkgs.openssh}/bin/:$PATH"

    ${lib.concatStringsSep "\n" [
      ''
        if [ ! -d "${exec.dst}" ]; then
          git clone "${exec.src}" "${exec.dst}"
          echo "✅  Cloned exec."
        fi
      ''
      ''
        if [ ! -d "${personal.dst}" ]; then
          git clone "${personal.src}" "${personal.dst}"
          echo "✅  Cloned personal."
        fi
      ''
      ''
        if [ ! -d "${secret.dst}" ]; then
          git clone "${secret.src}" "${secret.dst}"
          echo "✅  Cloned secret."
        fi
      ''
      ''
        if [ ! -d "${shortcuts.dst}" ]; then
          git clone "${shortcuts.src}" "${shortcuts.dst}"
          echo "✅  Cloned shortcuts."
        fi
      ''
      ''
        if [ ! -d "${nixos.dst}" ]; then
          git clone "${nixos.src}" "${nixos.dst}"
          echo "✅  Cloned nixos."
        fi
      ''
    ]}
  '';

  home.activation.setupDotfiles = lib.hm.dag.entryAfter ["cloneRepos"] ''
    ln -svf "${exec.dst}/etc/vimrc" ~/.vimrc
    ln -svf "${secret.dst}/etc/pypirc" ~/.pypirc
    ln -svf "${personal.dst}/etc/gitconfig" ~/.gitconfig
  '';

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
  # home.activation.setupNixosSymlinks = lib.hm.dag.entryAfter ["setupShortcuts"] ''
  #   if [ -d /etc/nixos ] && [ -f "${nixos.dst}/configuration.nix" ]; then
  #     sudo rm -rf /etc/nixos
  #     sudo ln -svf ${nixos.dst} /etc/nixos
  #     echo "✅ Symlinked /etc/nixos"
  #   fi
  # '';

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      for config_file in \
        "${exec.dst}/etc/bashrc" \
        "${personal.dst}/etc/bashrc" \
        "${secret.dst}/etc/bashrc"; do
        [ -f "$config_file" ] && source "$config_file"
      done

      if [ -d "${personal.dst}/etc/bash_completion.d" ]; then
        for f in "${personal.dst}"/etc/bash_completion.d/*; do
          [ -f "$f" ] && source "$f"
        done
      fi
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

}
