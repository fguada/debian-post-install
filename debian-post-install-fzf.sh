#!/bin/sh
# shellcheck disable=SC2034,SC1110

# set -o errexit
# set -o nounset
# set -o noglob # "Disable pathname expansion"
# exec 2>|"$HOME/log.txt" # pour envoyer la sortie de xtrace dans un fichier
# set -o xtrace
# IFS='
# '
# IFS="$(printf '\n\t')" # par défaut: ' \n\t'

# À faire AVANT l'exécution de ce script:
# sudo apt install localepurge
# sudo apt install git fzf
# git clone https://github.com/fguada/debian-post-install
# cd ./debian-post-install
# sh ./debian-post-install-fzf.sh

###############
# UTILITAIRES #
###############

bold=$(tput bold)
reset=$(tput sgr0)

ask() {
  printf '%s [O|n] ' "$@"
  read -r ans

  case "$ans" in
    n* | N*) return 1 ;;
    *) return 0 ;;
  esac
}

has() {
  if ! command -v "$1"; then
    return 1
  fi
}

need() {
  echo "Ce script requiert $1."
  exit 1
}

check() {
  last_command_exit_code="$1"

  if [ "$last_command_exit_code" -eq 0 ]; then
    printf '%sOK%s' "${bold}" "${reset}"
  else
    printf '%sERREUR. Code: %s%s.' "${bold}" "${last_command_exit_code}" "${reset}"
  fi
}

install() {
  sudo apt install "$@"
}

install_name() {
  ask "Installation de $1."
}

#############
# FONCTIONS #
#############

fgdo_config_console() { # Configurer la console
  ask 'Configuration interactive de la console.' || return
  sudo dpkg-reconfigure console-setup
  check $?
}

fgdo_activate_tty2() { # Activer la tty2
  ask 'Activation de la tty2.' || return
  sudo systemctl enable getty@tty2.service
  check $?
}

fgdo_backup_apt_sources() { # Sauvegarder les sources d’apt
  # Si la copie existe déjà, on ne l'écrase pas.
  if ! [ -e /etc/apt/sources.list.d/debian.sources.bak ]; then
    ask 'Création d’une copie de sauvegarde du fichier « /etc/apt/sources.list.d/debian.sources ».' || return
    sudo cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak
    check $?
  fi
}

fgdo_config_apt_sources() { # Configurer les sources d’apt
  ask 'Ajout des composants « contrib » et « non-free » au fichier « /etc/apt/sources.list.d/debian.sources ».' || return
  sudo sed --in-place 's/main non-free-firmware$/main non-free-firmware contrib non-free/g' /etc/apt/sources.list.d/debian.sources
  check $?
}

fgdo_add_apt_backports() { # Ajouter les backports aux sources d’apt
  ask 'Ajout de la suite debian-backports.' || return
  echo "Types: deb deb-src
URIs: http://deb.debian.org/debian
Suites: $(lsb_release --codename --short)-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
Enabled: yes" | sudo tee /etc/apt/sources.list.d/debian-backports.sources

  check $?
}

fgdo_update_apt() { # Mettre à jour le cache d’apt
  ask 'Mise à jour de la liste des paquets.' || return
  sudo apt update
  check $?
}

fgdo_upgrade_apt() { # Mettre à jour
  ask 'Installation d’éventuelles mises à jour des paquets.' || return
  sudo apt upgrade
  check $?
}

fgdo_install_cutom_pkgs() { # Installer une sélection personnalisée de paquets
  # On installe les paquets non commentés spécifiés dans ce fichier, situé dans le même répertoire que notre script.
  list="$(dirname "$(realpath "$0")")/packages.txt"
  ask 'Installation d’un choix personnel de paquets.' || return
  echo
  printf 'Pour consulter ou modifier la liste, voir le fichier « %s ».' "$list"
  pkgs="$(grep --only-matching --extended-regexp '^\s*[a-z0-9.+-]+' "$list")"

  # shellcheck disable=SC2086 # On veut séparer les paquets.
  install $pkgs
  check $?
}

fgdo_config_libdvd() { # Configurer libdvd
  ask 'Configuration de libdvd.' || return
  sudo dpkg-reconfigure libdvd-pkg
  check $?
}

fgdo_install_extrepo() { # Installer extrepo
  # https://linuxiac.com/how-to-use-extrepo-in-debian-to-manage-third-party-repositories/
  ask 'Installation et configuration d’« extrepo », logiciel permettant d’ajouter de manière sûre des dépôts externes.' || return
  sudo apt install extrepo
  sudo sed --in-place 's/^# - contrib/- contrib/' /etc/extrepo/config.yaml
  sudo sed --in-place 's/^# - non-free/- non-free/' /etc/extrepo/config.yaml
  check $?
}

fgdo_create_dirs() { # Créer des répertoires utiles
  ask 'Création de répertoires nécessaires.' || return

  userdirs="\
$HOME/Projets
$HOME/bin
$HOME/.local/bin
$HOME/.local/share
$HOME/.local/state/bash
$HOME/.config
$HOME/.cache/fg"

  for dir in $userdirs; do
    mkdir --parents "$dir"
  done

  systemdirs="\
/usr/local/bin
/usr/local/share/man/man1
/usr/local/share/bash-completion/completions"

  for dir in $systemdirs; do
    sudo mkdir --parents "$dir"
  done

  # Au cas où ce ne serait pas le cas… Nécessaire pour utiliser brightnessctl sans sudo.
  sudo usermod -a -G video "$USER"

  check $?
}

fgdo_export_env_vars() { # Exporter des variables d’environnement
  ask 'Ajouts de variables d’environnement utiles.' || return
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_CACHE_HOME="$HOME/.cache"
  export XDG_DATA_HOME="$HOME/.local/share"
  export XDG_STATE_HOME="$HOME/.local/state"
  export CARGO_HOME="$XDG_DATA_HOME"/cargo
  export GOPATH="$XDG_DATA_HOME"/go
  export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
  PATH="$HOME/.local/bin:$PATH"
  PATH="$HOME/bin:$PATH"
  export PATH
  check $?
}

fgdo_install_dra() { # Installer dra
  install_name dra || return
  curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/devmatteini/dra/refs/heads/main/install.sh | bash -s
  chmod +x ./dra
  sudo mv --force ./dra /usr/local/bin/

  if [ "$SHELL" = 'bash' ]; then
    dra completion bash > ./dra
    sudo mv --force ./dra /usr/local/share/bash-completion/completions/
  fi

  check $?
}

# https://github.com/jamielinux/bashmount/
fgdo_install_bashmount() { # Installer bashmount
  install_name bashmount || return
  curl --remote-name https://raw.githubusercontent.com/jamielinux/bashmount/master/bashmount
  chmod +x ./bashmount
  sudo mv --force ./bashmount /usr/local/bin/
  curl --remote-name https://raw.githubusercontent.com/jamielinux/bashmount/refs/heads/master/bashmount.1
  sudo mv --force ./bashmount.1 /usr/local/share/man/man1/
  check $?
}

# Disponible dans Debian à partir de Forky
# https://github.com/sharkdp/pastel
fgdo_install_pastel() { # Installer pastel
  install_name pastel || return
  dra download --select "pastel_{tag}_amd64.deb" sharkdp/pastel
  install ./pastel*.deb
  rm ./pastel*.deb
  check $?
}

# https://github.com/arp242/uni
fgdo_install_uni() { # Installer uni
  install_name uni || return
  dra download --select "uni-v{tag}-linux-amd64.gz" arp242/uni
  atool --extract uni*.gz
  rm --force uni*.gz
  sudo mv --force uni-v*-linux-amd64 /usr/local/bin/uni
  sudo chmod +x /usr/local/bin/uni
  check $?
}

fgdo_install_most_recent_fzf() { # Installer la version la plus récente de fzf
  install_name fzf || return
  dra download --select "fzf-{tag}-linux_amd64.tar.gz" junegunn/fzf
  atool --extract ./fzf*.gz
  rm --force ./fzf*.gz
  sudo mv --force ./fzf /usr/local/bin/
  sudo chmod +x /usr/local/bin/fzf
  curl --remote-name https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/man/man1/fzf.1
  fzf_local_man_path=/usr/local/share/man/man1/
  sudo mkdir --parents "$fzf_local_man_path"
  sudo mv --force ./fzf.1 "$fzf_local_man_path"
}

fgdo_install_most_recent_lf() { # Installer la version la plus récente de lf
  install_name lf || return
  dra download --select "lf-linux-amd64.tar.gz" gokcehan/lf
  atool --extract ./lf*.gz
  rm --force ./lf*.gz
  sudo mv --force ./lf /usr/local/bin/
  sudo chmod +x /usr/local/bin/lf
  curl --remote-name https://raw.githubusercontent.com/gokcehan/lf/refs/heads/master/lf.1
  lf_local_man_path=/usr/local/share/man/man1/
  sudo mkdir --parents "$lf_local_man_path"
  sudo mv --force ./lf.1 "$lf_local_man_path"
}

# https://github.com/ouch-org/ouch
fgdo_install_ouch() { # Installer ouch
  install_name ouch || return
  dra download --select "ouch-x86_64-unknown-linux-gnu.tar.gz" ouch-org/ouch
  atool --extract ouch-x86_64-unknown-linux-gnu.tar.gz
  sudo mv --force ./ouch-x86_64-unknown-linux-gnu/ouch /usr/local/bin/
  sudo chmod +x /usr/local/bin/ouch
  sudo mv --force ./ouch-x86_64-unknown-linux-gnu/completions/ouch.bash /usr/local/share/bash-completion/completions/
  sudo mv --force ./ouch-x86_64-unknown-linux-gnu/man/* /usr/local/share/man/man1/
  rm -rf ./ouch-*
  check $?
}

# https://github.com/walles/moor
fgdo_install_moor() { # Installer moor
  install_name moor || return
  dra download --select "moor-v{tag}-linux-amd64" walles/moor
  sudo mv --force moor-*-*-* /usr/local/bin/moor
  sudo chmod +x /usr/local/bin/moor
  curl --remote-name https://raw.githubusercontent.com/walles/moor/refs/heads/master/moor.1
  sudo mv --force ./moor.1 /usr/local/share/man/man1/
  check $?
}

# https://github.com/printfn/fend
fgdo_install_fend() { # Installer fend
  install_name fend || return
  dra download --select "fend-{tag}-linux-x86_64-gnu.zip" printfn/fend
  atool --extract fend-*-linux-x86_64-gnu.zip
  sudo mv --force fend /usr/local/bin/
  sudo chmod +x /usr/local/bin/fend
  dra download --select "fend.1" printfn/fend
  sudo mv --force ./fend.1 /usr/local/share/man/man1/
  rm ./fend-*
  check $?
}

# https://github.com/sharkdp/diskus
fgdo_install_diskus() { # Installer diskus
  install_name diskus || return
  dra download --select "diskus_{tag}_amd64.deb" sharkdp/diskus
  install ./diskus*.deb
  sudo rm ./diskus*.deb
  check $?
}

# https://github.com/flacon/flacon
fgdo_install_flacon() { # Installer flacon
  install_name flacon || return
  # Les AppImages semblent mal fonctionner sous wayland.
  dra download --select "flacon-{tag}-x86_64.AppImage" flacon/flacon
  sudo mv flacon-*-*.AppImage /usr/local/bin/
  sudo chmod +x /usr/local/bin/flacon-*-*.AppImage
  check $?
}

# https://github.com/jarun/advcpmv
fgdo_install_advcpmv() { # Installer advcpmv
  ask 'Installation de advcpmv (peut prendre quelques minutes). ' || return
  cd "$HOME/Projets" || exit 1

  if [ -e "./advcpmv/install.sh" ]; then
    cd ./advcpmv || exit 1
    sh ./install.sh
  else
    curl https://raw.githubusercontent.com/jarun/advcpmv/master/install.sh --create-dirs -o ./advcpmv/install.sh && (cd advcpmv && sh install.sh)
  fi

  sudo mv --force "$HOME"/Projets/advcpmv/advcp /usr/local/bin/cpg
  sudo mv --force "$HOME"/Projets/advcpmv/advmv /usr/local/bin/mvg
  sudo chmod +x /usr/local/bin/cpg /usr/local/bin/mvg
  check $?
}

# https://github.com/laurent22/massren
fgdo_install_massren() { # Installer massren
  install_name massren || return
  has go || install golang
  go install github.com/laurent22/massren@latest
  sudo cp --force "$GOPATH/bin/massren" /usr/local/bin/
  check $?
}

# https://github.com/sentriz/cliphist
# J'ai besoin d'une version >= 0.6, or au 14/03/2025, debian testing n'a encore que 0.5.
# Pas de bogue si j'utilise une version < 0.6, l'option de contrôle de la longueur des lignes de prévisualisation est simplement ignorée.
fgdo_install_cliphist() { # Installer cliphist
  install_name cliphist || return
  has go || install golang
  go install go.senan.xyz/cliphist@latest
  sudo cp --force "$GOPATH/bin/cliphist" /usr/local/bin/
  check $?
}

# https://github.com/MaxVerevkin/wl-gammarelay-rs
fgdo_install_wl_gammarelay_rs() { # Installer wl_gammarelay_rs
  ask 'Installation de wl-gammarelay-rs (peut prendre quelques minutes). ' || return
  has cargo || install cargo
  cargo install wl-gammarelay-rs --locked
  sudo cp --force "$CARGO_HOME/bin/wl-gammarelay-rs" /usr/local/bin/
  sudo chmod +x /usr/local/bin/wl-gammarelay-rs
  check $?
}

# https://vscodium.com/
fgdo_install_vscodium() { # Installer VSCodium
  install_name VSCodium || return
  sudo extrepo enable vscodium
  sudo apt update && sudo apt install codium
  check $?
}

fgdo_install_tor() { # Installer tor
  install_name Tor || return
  sudo extrepo enable torproject
  sudo apt update && sudo apt install tor torbrowser-launcher
  check $?
}

fgdo_install_dotool() { # Installer dotool
  install_name dotool || return
  cd "$HOME/Projets" || exit 1

  if [ -d "./dotool" ]; then
    cd ./dotool || exit 1
    git pull
  else
    git clone https://git.sr.ht/~geb/dotool
    cd ./dotool || exit 1
  fi

  ./build.sh && sudo ./build.sh install
  sudo groupadd -f input
  sudo usermod -a -G input "$USER"
}

# https://github.com/electrickite/batsignal/
fgdo_install_batsignal() { # Installer batsignal
  install_name batsignal || return
  cd "$HOME/Projets" || exit 1

  if [ -d "./batsignal" ]; then
    cd ./batsignal || exit 1
    git pull
  else
    git clone https://github.com/electrickite/batsignal
    cd ./batsignal || exit 1
  fi

  make && sudo make install
  check $?
}

# J'ai besoin d'une version de wl-clipboard postérieure à ce commit: https://github.com/bugaevc/wl-clipboard/commit/1e50b65d5ef94d2e595cfaf30a81f933ba80b1f9, daté du 24 mars 2025. Or aucune nouvelle version n'a été publiée depuis 2023.
# Ce commit permet à `wl-paste --watch` d'ignorer les mots de passe copiés dans keepassxc.
fgdo_install_wl_clipboard() { # Installer wl_clipboard
  install_name wl-clipboard || return
  cd "$HOME/Projets" || exit 1

  if [ -d "./wl-clipboard" ]; then
    cd ./wl-clipboard || exit 1
    git pull
  else
    git clone https://github.com/bugaevc/wl-clipboard.git
    cd ./wl-clipboard || exit 1
  fi

  meson setup build
  cd build || exit
  ninja
  sudo meson install
  check $?
}

# Ces logiciels s'installent dans /usr et non dans /usr/local. Malheureusement leurs makefiles ne respectent pas l'argument `--prefix /usr/local` qui pourrait être passé à `cmake`.
fgdo_install_hyprpicker() { # Installer hyperpicker
  install_name hyprpicker || return
  echo
  printf '%sCompilation préalable de hyprutils.%s\n' "${bold}" "${reset}"
  cd "$HOME/Projets" || exit 1

  if [ -d "./hyprutils" ]; then
    cd ./hyprutils || exit 1
    git pull
  else
    git clone https://github.com/hyprwm/hyprutils.git
    cd ./hyprutils || exit 1
  fi

  cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
  cmake --build ./build --config Release --target all -j"$(nproc 2> /dev/null || getconf NPROCESSORS_CONF)"
  sudo cmake --install build
  check $?

  echo
  printf '%sCompilation préalable de hyprwayland-scanner.%s\n' "${bold}" "${reset}"
  cd "$HOME/Projets" || exit 1

  if [ -d "./hyprwayland-scanner" ]; then
    cd ./hyprwayland-scanner || exit 1
    git pull
  else
    git clone https://github.com/hyprwm/hyprwayland-scanner.git
    cd ./hyprwayland-scanner || exit 1
  fi

  cmake -DCMAKE_INSTALL_PREFIX=/usr -B build
  cmake --build build -j "$(nproc)"
  sudo cmake --install build
  check $?

  echo
  printf '%sCompilation de hyprpicker.%s\n' "${bold}" "${reset}"
  cd "$HOME/Projets" || exit 1

  if [ -d "./hyprpicker" ]; then
    cd ./hyprpicker || exit 1
    git pull
  else
    git clone https://github.com/hyprwm/hyprpicker.git
    cd ./hyprpicker || exit 1
  fi

  cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
  cmake --build ./build --config Release --target hyprpicker -j"$(nproc 2> /dev/null || getconf _NPROCESSORS_CONF)"
  sudo cmake --install ./build
  check $?
}

# https://github.com/cytopia/linux-timemachine
fgdo_install_timemachine() { # Installer timemachine
  install_name timemachine || return
  curl --remote-name https://raw.githubusercontent.com/cytopia/linux-timemachine/refs/heads/master/timemachine
  chmod +x ./timemachine
  sudo mv --force ./timemachine /usr/local/bin/
  check $?
}

# https://github.com/meersjo/toolkit/blob/master/various/datedirclean.sh
fgdo_install_datedirclean() { # Installer datedirclean
  install_name datedirclean.sh || return
  curl --remote-name https://raw.githubusercontent.com/meersjo/toolkit/refs/heads/master/various/datedirclean.sh
  chmod +x ./datedirclean.sh
  sudo mv --force ./datedirclean.sh /usr/local/bin/
  check $?
}

# https://github.com/labwc/labwc-gtktheme
fgdo_install_labwc_gtktheme() { # Installer labwc_gtktheme
  install_name labwc-gtktheme || return
  cd "$HOME/Projets" || exit 1

  if [ -d "./labwc-gtktheme" ]; then
    cd ./labwc-gtktheme || exit 1
    git pull
  else
    git clone https://github.com/labwc/labwc-gtktheme
    cd ./labwc-gtktheme || exit 1
  fi

  chmod +x ./labwc-gtktheme.py
  sudo cp ./labwc-gtktheme.py /usr/local/bin

  # La session graphique doit avoir été lancée au moins une fois avant que ce script python puisse fonctionner.
  # À ce point il tournerait de toute façon pour rien, puisque le thème Mint-Y-Purple n'est pas installé. Or ce thème ne peut être installé que manuellement.
  # labwc-gtktheme.py

  check $?
}

# https://brew.sh/
fgdo_install_homebrew() { # Installer homebrew
  install_name homebrew || return
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  check $?
}

# https://eid.belgium.be/fr/installation-du-logiciel-eid-sous-linux
fgdo_install_eid_belgium() { # Installer eid_belgium
  install_name 'eID Belgium' || return
  curl --remote-name https://eid.belgium.be/sites/default/files/software/eid-archive_latest.deb
  install ./eid-archive_latest.deb
  sudo apt update && install eid-viewer eid-mw
  rm ./eid-archive_latest.deb
  check $?
}

# https://signal.org/
fgdo_install_signal() { # Installer signal
  install_name 'Signal Desktop' || return
  sudo extrepo enable signal
  sudo apt update && sudo apt install signal-desktop
  check $?
}

fgdo_install_emailbook() { # Installer emailbook
  has aerc || return
  install_name 'emailbook (pour aerc)' || return
  curl --remote-name https://git.sr.ht/~maxgyver83/emailbook/blob/main/emailbook
  chmod +X ./emailbook
  sudo mv ./emailbook /usr/local/bin/
  check $?
}

fgdo_correct_perms() { # Corriger les permissions
  ask 'Correction des permissions des répertoires du système.' || return
  sudo chmod 755 /usr/local/bin/*
  sudo chown root:root /usr/local/bin/*
  check $?
}

# 2025-11-29: ces fichiers sont désormais copiés de ma sauvegarde par la fonction copy_data.
# fgdo_config_logind() { # Configurer logind
#   ask 'Configuration de « /etc/systemd/logind.conf ».' || return
#   sudo sed --in-place 's/^#HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
#   sudo sed --in-place 's/^#IdleAction=.*/IdleAction=suspend/' /etc/systemd/logind.conf
#   sudo sed --in-place 's/^#IdleActionSec=.*/IdleActionSec=4min/' /etc/systemd/logind.conf
#   check $?
# }

fgdo_config_grub() { # Configurer grub
  ask 'Configuration de grub.' || return
  sudo sed --in-place 's/GRUB_TIMEOUT=./GRUB_TIMEOUT=2/' "/etc/default/grub"
  sudo update-grub
  check $?
}

fgdo_make_symlinks() { # Créer des liens symboliques
  ask 'Établissement de liens symboliques de batcat et fdfind vers bat et fd.' || return
  sudo ln -s /usr/bin/batcat /usr/local/bin/bat
  sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
  check $?
}

fgdo_create_root_passwd() { # Créer le mot de passe du compte root
  ask 'Création du mot de passe du compte root.' || return
  sudo passwd root
  check $?
}

fgdo_config_apt_colors() { # Configurer apt en couleur
  ask 'Configuration des couleurs d’apt.' || return
  apt_conf_dir='/etc/apt/apt.conf.d'
  apt_color_conf='21-colors.conf'
  test ! -d "$apt_conf_dir" && sudo mkdir --parents "$apt_conf_dir"
  echo 'APT::Color::Action::Upgrade "blue";' | sudo tee "$apt_conf_dir/$apt_color_conf"
  check $?
}

fgdo_add_rescue_user() { # Ajouter un utilisateur de secours
  user_name=toto
  ask "Ajout d’un utilisateur de secours: ${user_name}." || return
  # `adduser` est une commande spécifique à Debian et à ses dérivées.
  sudo adduser "$user_name"
  check $?
}

fgdo_config_custom_desktop_files() { # Créer des fichiers .desktop personnalisés
  ask 'Configuration d’un fichier desktop personnalisé pour quelques applications.' || return
  sudo mkdir --parents /usr/local/share/applications
  mkdir --parents ~/.local/share/applications

  if command -v mpv > /dev/null; then
    echo 'mpv'
    sudo cp --force /usr/share/applications/mpv.desktop /usr/local/share/applications/
    sudo sed --in-place -E 's/^Exec=.+$/Exec=mpv --fullscreen --player-operation-mode=pseudo-gui -- %U/' /usr/local/share/applications/mpv.desktop
    check $?
  fi

  if command -v vlc > /dev/null; then
    echo
    echo 'vlc'
    sudo cp --force /usr/share/applications/vlc.desktop /usr/local/share/applications/
    sudo sed --in-place -E 's_^Exec=.+$_Exec=/usr/bin/vlc --fullscreen --playlist-enqueue --one-instance-when-started-from-file --started-from-file %U_' /usr/local/share/applications/vlc.desktop
    check $?
  fi

  if command -v zathura > /dev/null; then
    echo
    echo 'zathura'
    sudo cp --force /usr/share/applications/org.pwmt.zathura.desktop /usr/local/share/applications/
    echo 'MimeType=application/x-cbr;application/x-rar;application/x-cbz;application/zip;application/x-cb7;application/x-7z-compressed;application/x-cbt;application/x-tar;inode/directory;image/vnd.djvu;image/vnd.djvu+multipage;application/pdf;application/postscript;application/eps;application/x-eps;image/eps;image/x-eps;' | sudo tee --append /usr/local/share/applications/org.pwmt.zathura.desktop
    # echo
    check $?
  fi

  # Configuration dans le répertoire personnel de l'utilisateur, car dépendant d'un script qui n'est pas globalement accessible.
  if command -v run-gui-root-wl.sh > /dev/null; then
    if command -v timeshift > /dev/null; then
      echo
      echo 'timeshift'
      cp --force /usr/share/applications/timeshift-gtk.desktop ~/.local/share/applications/
      sed --in-place 's/^Exec=/Exec=run-gui-root-wl.sh /' ~/.local/share/applications/timeshift-gtk.desktop
      # echo
      check $?
    fi

    if command -v /sbin/gparted > /dev/null; then
      echo
      echo 'gparted'
      cp --force /usr/share/applications/gparted.desktop ~/.local/share/applications/
      sed --in-place 's/^Exec=/Exec=run-gui-root-wl.sh /' ~/.local/share/applications/gparted.desktop
      # echo
      check $?
    fi
  fi
}

# 2025-11-29: ces fichiers sont désormais copiés de ma sauvegarde par la fonction copy_data.
# fgdo_decrease_systemd_timeout() { # Diminuer la longueur du compte à rebours de sortie de systemd
#   ask 'Diminution drastique du temps d’attente qu’un job se termine à la déconnexion.' || return
#   sudo mkdir --parents /etc/systemd/logind.conf.d/
#   printf '# Fichier créé par le script %s.\n\nDefaultTimeoutStopSec=5s\nDefaultTimeoutAbortSec=10s' "$(basename "$0")" \
#     | sudo tee /etc/systemd/logind.conf.d/timeoutstop.conf
#   sudo systemctl daemon-reload
#   check $?
# }

fgdo_copy_data() { # Copier les données
  ask 'Copie de données personnelles d’un périphérique de stockage externe.' || return
  if ! command -v bashmount > /dev/null; then
    printf '%sbashmount n’est pas installé. Ce logiciel est nécessaire à cette étape. Abandon.%s ' "${bold}" "${reset}"
    return
  fi

  echo
  printf '%sInsérez maintenant le périphérique de stockage externe contenant les données à copier, puis pressez « entrée ».%s\nLe logiciel bashmount sera exécuté, vous permettant de monter le périphérique inséré. ' "${bold}" "${reset}"
  if test ! "$DISPLAY"; then
    # Nécessaire pour que polkit soit actif, lequel est nécessaire à bashmount pour monter un volume en tant qu'utilisateur standard. Mais si la variable d'environnement DISPLAY existe, nous ne sommes plus en console et dbus a nécessairement redémarré depuis l'installation. Cette commande fait crasher la session graphique.
    echo
    echo 'Préalable indispensable: redémarrage de dbus.'
    sudo systemctl restart dbus
    check $?
  fi

  bashmount

  echo
  printf '%sSaisissez maintenant le chemin complet du dossier « Sauvegarde » à copier.%s\nCe chemin est habituellement de la forme « /media/%s/<volume>/Sauvegarde/<machine>/ ».\n(Il peut être vérifié dans une autre tty.)\nChemin: ' "${bold}" "${reset}" "$USER"
  read -r my_path

  if ! [ -d "$my_path" ]; then
    echo
    echo "${bold}ERREUR: « $my_path » n’est pas un dossier! Abandon.${reset}"
    return
  fi

  if ! [ -d "${my_path}/home/${USER}" ]; then
    echo
    echo "${bold}ERREUR: « ${my_path}/home/${USER} » n’existe pas! Abandon.${reset}"
    return
  fi

  echo
  echo "Copie du contenu de « ${my_path}/home/$USER/ » dans « ${HOME}/ »."
  echo

  my_cp() {
    if ! command -v cpg > /dev/null; then
      cp --strip-trailing-slashes --reflink=auto --no-preserve=mode,ownership --recursive --force -- "$1" "$2"
    else
      cpg --strip-trailing-slashes --reflink=auto --no-preserve=mode,ownership --recursive --force --progress-bar -- "$1" "$2"
    fi
  }

  my_cp "${my_path}/home/${USER}/." "$HOME/"
  check $?

  # Copie d'éléments que j'ai sans doute personnalisés.
  echo
  echo "Copie du contenu personnalisé de « ${my_path}/usr/local/ » dans « /usr/local/ »."
  echo

  # Si le répertoire existe et n'est pas vide…
  if [ -d "$my_path/usr/local/share/pixmaps" ] && [ "$(ls -A "$my_path/usr/local/share/pixmaps")" ]; then
    sudo mkdir --parents /usr/local/share/pixmaps
    sudo sh -c my_cp "$my_path/usr/local/share/pixmaps/." /usr/local/share/pixmaps/
  fi

  check $?

  echo
  echo "Copie du contenu personnalisé de « ${my_path}/etc/ » dans « /etc/ »."
  echo

  set -- \
    journald \
    logind \
    sleep \
    system \
    user

  path='/etc/systemd'

  for dir in "$@"; do
    sudo mkdir --parents "${path}/${dir}.conf.d"
    # sudo touch "${path}/${dir}.conf.d/90-fg-override-${dir}.conf"
    sudo sh -c my_cp "${my_path}/${path}/${dir}".conf.d/. "${path}/${dir}".conf.d/
  done

  if [ -e "$my_path/etc/issuefg" ]; then
    sudo sh -c my_cp "$my_path/etc/issuefg" /etc/
  fi

  check $?
}

fgdo_make_exec() { # Rendre exécutables les scripts qui doivent l’être
  ask 'Correction des permissions des répertoires « bin » personnels.' || return
  # Uniquement si ces répertoires ne sont pas vides.
  if [ "$(ls -A ~/bin)" ]; then
    chmod +x ~/bin/*
  fi

  if [ "$(ls -A ~/.local/bin)" ]; then
    chmod +x ~/.local/bin/*
  fi

  check $?
}

fgdo_config_keyboard() { # Configurer le clavier
  if [ -e "${XDG_CONFIG_HOME:-$HOME/.config}/xkb/symbols/custom" ]; then
    ask 'Configuration du clavier personnalisé « custom ».' || return

    echo
    printf '%sÉtablissement d’un lien symbolique entre mon clavier personnalisé et le clavier « custom » du système.%s ' "${bold}" "${reset}"
    sudo ln -s "${XDG_CONFIG_HOME:-$HOME/.config}/xkb/symbols/custom" "/usr/share/X11/xkb/symbols/"
    check $?

    echo
    printf '%sConfiguration du fichier système « /etc/default/keyboard ».%s ' "${bold}" "${reset}"
    echo '# KEYBOARD CONFIGURATION FILE
# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="custom"
XKBOPTIONS="terminate:ctrl_alt_bksp,compose:rctrl-altgr,nbsp:level3n,kpdl:comma,numpad:mac"
BACKSPACE="guess"' \
      | sudo tee /etc/default/keyboard
    check $?

    ask 'Inversion des touches Home/End et Page Up/Down.' || return

    echo 'XKBVARIANT="fg_invert_home_end_with_pageup_pagedown"' \
      | sudo tee --append /etc/default/keyboard
    check $?

    echo
    printf '%sSynchronisation des changements avec la console.%s ' "${bold}" "${reset}"
    sudo setupcon
    check $?
  fi
}

fgdo_config_lf() { # Configurer lf
  has lf || return
  ask 'Configuration de lf.' || return
  mkdir --parents "${XDG_DATA_HOME:-$HOME/.local/share}/lf"
  ln -s "${XDG_CONFIG_HOME:-$HOME/.config}/lf/marks" "${XDG_DATA_HOME:-$HOME/.local/share}/lf/"
  # Rendre exécutable le script de nettoyage des images affichées par lf dans kitty.
  chmod +x "${XDG_CONFIG_HOME:-$HOME/.config}/lf/lf_kitty_clean"
  check $?
}

fgdo_correct_ssh_perms() { # Corriger les permissions de ssh
  if [ -d "$HOME/.ssh/" ] && [ "$(ls -A "$HOME/.ssh/")" ]; then
    ask 'Correction des permissions de mes clés ssh.' || return
    chmod 600 ~/.ssh/*
    check $?
  fi
}

fgdo_config_default_editor() { # Configurer l’éditeur de texte par défaut
  ask 'Configuration de l’éditeur de texte par défaut.' || return
  sudo update-alternatives --config editor
  check $?
}

## Désactiver certains services inutiles (il peut aussi être nécessaires de les masquer, pour empêcher que d'autres processus ne les relancent).
fgdo_config_systemd_services() { # Configurer des services de systemd
  ask 'Configuration de services de systemd.' || return
  systemctl --user disable gvfs-goa-volume-monitor.service
  systemctl --user mask gvfs-goa-volume-monitor.service
  sudo systemctl disable ModemManager.service
  sudo systemctl disable cups.service
  sudo systemctl disable cups-browsed.service
  sudo systemctl disable accounts-daemon
  sudo systemctl mask accounts-daemon
  check $?
}

fgdo_config_thunar() { # Configurer thunar
  has thunar || return
  ask 'Configuration de Thunar.' || return
  thunar -q
  # toujours afficher le chemin complet dans la barre de titre de Thunar
  # pour Thunar 4.18 (mais mieux vaut peut-être l'option qui affiche le chemin complet dans le titre de l'onglet; ce qui me permet d'activer l'option de cacher la barre de titre des fenêtres maximisées)
  xfconf-query --channel thunar --property /misc-full-path-in-window-title --create --type bool --set true
  # afficher les onglets même quand un seul est ouvert; utile si j'active l'option qui masque le titre des fenêtres maximisées
  xfconf-query --channel thunar --property /misc-always-show-tabs --create --type bool --set true
  check $?
}

fgdo_config_xfce_panel() { # Configurer le panneau de Xfce
  has xfce4-panel || return
  ask 'Configuration de xfce4-panel.' || return
  # Désactiver l'animation de masquage automatique du tableau de bord d'Xfce.
  xfconf-query -n -c xfce4-panel -p /panels/panel-1/popdown-speed -t int -s 0
  # Les délais de masquage et la hauteur résiduelle du tableau de bord peuvent être configurés avec du css.
  # Voir https://docs.xfce.org/xfce/xfce4-panel/preferences.
  check $?

}

fgdo_config_xfce_session() { # Configurer la sessions de Xfce
  has xfce4-session || return
  ask 'Configuration de xfce4-session.' || return
  # Désactiver le lancement automatique de gpg et ssh.
  xfconf-query -c xfce4-session -p /startup/ssh-agent/enabled -n -t bool -s false
  xfconf-query -c xfce4-session -p /startup/gpg-agent/enabled -n -t bool -s false
  check $?
}

fgdo_config_documents_hourly_backup() { # Configurer une sauvegarde horaire des documents
  has timemachine \
    && has datedirclean.sh \
    && has sauvegarde_locale_timemachine_Documents.sh || return
  ask 'Configuration de la sauvegarde horaire des documents cruciaux.' || return

  # Création du répertoire de sauvegardes locales.
  sudo mkdir --parents "/home/sauvegardes/$USER/Documents"

  # Ajustement du propriétaire dudit répertoire.
  sudo chown --changes --recursive "$USER":"$USER" "/home/sauvegardes/$USER"

  # Ajustement des permissions dudit répertoire.
  sudo chmod 700 "/home/sauvegardes/$USER"

  # Paramétrage de la fréquence de la sauvegarde.
  echo "@hourly $(which sauvegarde_locale_timemachine_Documents.sh)" | crontab -

  # Paramétrage de la suppression automatique des sauvegardes les plus anciennes.
  echo "
# FG
# tous les 7 jours, suppression des anciennes sauvegardes locales effectuées chaque heure avec linux-timemachine via cron
7 15 fg-suppression-des-anciennes-sauvegardes-locales	$(which datedirclean.sh) /home/sauvegardes/$USER/Documents" \
    | sudo tee --append /etc/anacrontab

  check $?
}

fgdo_config_mime() { # Configurer des associations de fichiers
  has fset-default-app-for-mime-category.sh || return
  ask 'Configuration de l’association d’une application à toute une catégorie de types mime.' || return
  has codium && fset-default-app-for-mime-category.sh text codium
  has qimgv && fset-default-app-for-mime-category.sh image qimgv
  has vlc && fset-default-app-for-mime-category.sh audio vlc
  has mpv && fset-default-app-for-mime-category.sh video mpv
  check $?
}

fgdo_config_tty1_nameless_login() { # Configurer la connexion sans entrer le nom sur la tty1
  ask 'Configuration de la connexion sans nom d’utilisateur sur la tty1.' || return
  echo
  echo 'Préalable: création du fichier « /etc/issuefg ».'
  echo

  printf '\S \\n \l\n\nWelcome %s!\nPlease enter your password…\n' "$(getent passwd "$USER" | cut -d":" -f5 | cut -d"," -f1)" \
    | sudo tee /etc/issuefg
  check $?

  echo
  echo 'Configuration de la tty1'
  echo
  sudo mkdir --parents "/etc/systemd/system/getty@tty1.service.d"

  echo "[Service]
ExecStartPre='/lib/console-setup/console-setup.sh'
ExecStart=
ExecStart=-/sbin/agetty --issue-file /etc/issuefg -o '-p -- $USER' --noclear --skip-login - \$TERM" \
    | sudo tee "/etc/systemd/system/getty@tty1.service.d/90-fg-override-tty1.conf"

  check $?
}

fgdo_config_shell_options_and_aliases() { # Configurer les options et alias du shell
  ask 'Configuration des options et alias par défaut du shell.' || return
  # shellcheck disable=SC2016
  echo '
######
# FG #
######

######################
# ALIAS ET FONCTIONS #
######################

# toujours afficher la liste des fichiers avec 1 élément par lignes sauf . et ..
alias ls="ls --group-directories-first --human-readable --classify -l --color=auto --time-style=+\"%Y-%m-%d %H:%M:%S\""

# toujours afficher la liste des fichiers avec 1 élément par lignes, les éléments invisibles sauf . et .. ; mnémonique: "ls all"
alias lsa="ls --group-directories-first --human-readable --classify -l --color=auto --time-style=+\"%Y-%m-%d %H:%M:%S\" --almost-all"

alias ..="cd .."         # Go up one directory
alias cd..="cd .."       # Common misspelling for going up one directory
alias ...="cd ../.."     # Go up two directories
alias ....="cd ../../.." # Go up three directories

# settings that you pretty much just always are going to want
alias \
  rm="rm --interactive=once --force --verbose --recursive --one-file-system" \
  bc="bc --quiet" \
  mkdir="mkdir --parents --verbose"

# Une version de cp conforme à mon habitude des gestionnaires de fichiers graphiques: une barre de progression pour les opérations lentes, et une adaptation des propriétés des fichiers copiés au dossier dans lequel ils l’ont été (par défaut cp copie les propriétés de la source).
if command -v cpg >/dev/null; then
  alias cp="cpg --strip-trailing-slashes --reflink=auto --recursive --no-preserve=mode,ownership --progress-bar"
fi

if command -v mvg >/dev/null; then
  alias mv="mvg --strip-trailing-slashes --progress-bar"
fi

if command -v lf >/dev/null 2>/dev/null; then	
  l() {
  	cd "$(lf -print-last-dir "$@")" || return
  }
fi

# df pour les humains!
alias df="df --local --human-readable --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=efivarfs --output=target,size,used,avail,pcent,fstype,source"

if command -v duf >/dev/null 2>/dev/null; then
  # afficher la taille et l’espace libre des volumes; alternative plus jolie à df
  alias duf="duf --only local"
fi

if command -v dust >/dev/null 2>/dev/null; then
  # afficher les dossiers triés par taille; alternative plus jolie à du (à partir de trixie)
  alias dust="dust --limit-filesystem"
fi

du() {
  if command -v diskus >/dev/null 2>/dev/null; then
    # Affichage identique à du -sh ci-dessous, mais plus rapide car parallélisé.
    diskus # https://github.com/sharkdp/diskus
  else
    du --summarize --human-readable --one-file-system
  fi
}

###########
# CLAVIER #
###########

# faire en sorte que ctrl+backspace efface le mot précédent
stty werase "^H"

##########################################
# OPTIONS SPÉCIFIQUES À BASH #
##########################################

## GENERAL OPTIONS ##
## https://github.com/mrzool/bash-sensible/blob/master/sensible.bash

# Prevent file overwrite on stdout redirection
# Use `>|` to force redirection to an existing file
set -o noclobber

# Update window size after every command:
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Turn on recursive globbing (enables ** to recurse all directories)
# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar 2>/dev/null

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

## SANE HISTORY DEFAULTS ##

# Append to the history file, don’t overwrite it
shopt -s histappend

# Save multi-line commands as one command
shopt -s cmdhist

# After each command, append to the history file and reread it
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Huge history. Doesn’t appear to slow things down, so why not?
HISTSIZE=5000
HISTFILESIZE=10000

# Don’t record some commands
export HISTIGNORE="&:[ ]*:exit:cd*:ls:bg:fg:history:clear:hs:*.sh:bm:bp:lsa:..:...:...."

# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)
HISTTIMEFORMAT="%F %T "

## BETTER DIRECTORY NAVIGATION ##

# Prepend cd to directory names automatically
shopt -s autocd
# Correct spelling errors during tab-completion
shopt -s dirspell
# Correct spelling errors in arguments supplied to cd
shopt -s cdspell
' \
    | sudo tee --append '/etc/skel/.bashrc'

  if [ -f "$XDG_CONFIG_HOME/readline/inputrc" ]; then
    sudo cp --force "$XDG_CONFIG_HOME/readline/inputrc" /etc/skel/.inputrc
  fi

  # Copie des fichiers par défaut dans les répertoires home des utilisateurs.
  sudo cp --force --recursive /etc/skel/. /root/

  if [ -d /home/toto ]; then
    sudo cp --force --recursive /etc/skel/. /home/toto/
  fi

  check $?
}

fgdo_create_dollar_script() { # Créer le script $
  ask 'Créer dans /usr/local/bin un script permettant d’exécuter une ligne commençant par un dollar.' || return
  printf '#!/bin/sh\neval "$*"' | sudo tee /usr/local/bin/$
  sudo chmod +x /usr/local/bin/$
  check $?
}

# 2025-11-29: ces fichiers sont désormais copiés de ma sauvegarde par la fonction copy_data.
# fgdo_forward_journald_to_tty12() { # Envoyer journald sur la tty12
#   # Cf. https://wiki.archlinux.org/title/Systemd/Journal#Forward_journald_to_/dev/tty12.
#   ask 'Affichage de journald sur la tty12.' || return
#   sudo mkdir --parents /etc/systemd/journald.conf.d
#   echo '[Journal]
# ForwardToConsole=yes
# TTYPath=/dev/tty12' | sudo tee /etc/systemd/journald.conf.d/90-fg-override-journald.conf
#   sudo systemctl restart systemd-journald.service
#   check $?
# }

fgdo_build_bat_cache() { # Construire le cache de bat
  # La construction du cache est nécessaire pour utiliser un thème personnalisé.
  has bat || return
  ask 'Construction du cache de bat.' || return
  bat cache --build
  check $?
}

fgdo_fgdo_update_locate_db() { # Mettre à jour la base de données de locate
  ask 'Création de la base de données générale de locate.' || return
  sudo updatedb
  check $?
}

fgdo_show_what_to_do_manually() { # Montrer ce qui reste à faire manuellement
  echo "
##########################################
# À FAIRE MANUELLEMENT ${bold}après redémarrage${reset} #
##########################################

- Activer Timeshift: sudo timeshift-gtk

- Supprimer les fichiers obsolètes suivants:
  - ~/.wget-hsts
  - ~/.bash_history

- Cloner en ssh mes repos:
  - git clone git@github.com:fguada/debian-post-install.git
  - git clone git@github.com:fguada/fguada.github.io.git

- Si l’installation a été faite en Wi-Fi, il est possible que ce soit dhcpcd qui prenne en charge les connexions Wi-Fi et non Network Manager, ce qui empêche de se connecter facilement à de nouveaux réseaux. Solution: supprimer toutes les autres interfaces que « lo » dans le fichier « /etc/network/interfaces », puis redémarrer.

- Installer les dernières versions des paquets ci-dessous pour utiliser le thème Mint-Y-Purple.
  mint-x-icons_*.*.*_all.deb # http://packages.linuxmint.com/pool/main/m/mint-x-icons/
  mint-y-icons_*.*.*_all.deb # http://packages.linuxmint.com/pool/main/m/mint-y-icons/
  mint-themes_*.*.*_all.deb # http://packages.linuxmint.com/pool/main/m/mint-themes/
- puis exécuter labwc-gtktheme.py (ainsi qu’à chaque mise à jour du thème).

- Copier la musique, les photos et vidéos.

- Éventuellement, installer grub-customizer, notamment pour modifier facilement la taille de la police.
  L'option « splash » peut être passée au noyau pour un démarrage plus discret visuellement.
  Le Dell Latitude 5500 nécessite que l'option « dis_ucode_ldr » soit passée au noyau.

- Si nécecessaire, installer format_sd: https://www.sdcard.org/downloads/sd-memory-card-formatter-for-linux/"
  echo
}

#############
# EXÉCUTION #
#############

has fzf || need fzf

echo
echo '##########################################'
echo "# ${bold}SCRIPT DE POST-INSTALLATION DE DEBIAN.${reset} #"
echo '##########################################'
echo
echo "Pressez « ${bold}entrée${reset} » pour confirmer chaque étape, « ${bold}n${reset} » puis « ${bold}entrée${reset} » pour la passer, ou « ${bold}ctrl-c${reset} » pour quitter."
read -r dummy

trap 'rm -f "$tempfile"' EXIT
tempfile="$(mktemp)"
SEP='\(\) \{ # '

grep -E --only-matching "^fgdo_.+${SEP}.+$" "$0" \
  | fzf \
    --ghost 'Choisir les fonctions à exécuter' \
    --header 'ctrl-a: tout sélectionner | tab: (dé)sélectionner' \
    --header-border \
    --delimiter "$SEP" \
    --with-nth 2 \
    --highlight-line \
    --cycle \
    --multi \
    --gutter ' ' \
    --gutter-raw ' ' \
    --info inline-right \
    --bind "enter:become(printf '%s\n' {+1} > $tempfile)"

test ! -s "$tempfile" && exit

# shellcheck disable=SC2013
for function in $(cat "$tempfile"); do
  echo
  "$function"
done

echo
echo '########'
echo "# ${bold}FIN.${reset} #"
echo '########'
echo
