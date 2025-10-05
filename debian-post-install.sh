#!/bin/sh
# shellcheck disable=SC2034,SC1110

#set -o errexit
# set -o nounset
# set -o noglob # "Disable pathname expansion"
#exec 2>|"$HOME/log.txt" # pour envoyer la sortie de xtrace dans un fichier
#set -o xtrace
# IFS="
# "
# IFS="$(printf '\n\t')" # par défaut: ' \n\t'

# À faire AVANT l'exécution de ce script:
# sudo apt install localepurge
# sudo apt install git
# git clone https://github.com/fguada/debian-post-install
# cd ./debian-post-install
# sh ./debian-post-install.sh

###############
# UTILITAIRES #
###############

bold=$(tput bold)
reset=$(tput sgr0)

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
  echo
  printf '%sInstallation de %s.%s ' "${bold}" "$1" "${reset}"
}

#############
# FONCTIONS #
#############

config_console() {
  echo
  printf '%sConfiguration interactive de la console.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo dpkg-reconfigure console-setup
  check $?
}

activate_tty2() {
  echo
  printf '%sActivation de la tty2.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo systemctl enable getty@tty2.service
  check $?
}

backup_apt_sourceslist() {
  # Si la copie existe déjà, on ne l'écrase pas.
  if ! [ -e /etc/apt/sources.list.bak ]; then
    echo
    printf '%sCréation d’une copie de sauvegarde du fichier « /etc/apt/sources.list ».%s ' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    check $?
  fi
}

config_apt_sourceslist() {
  echo
  printf '%sAjout des composants « contrib » et « non-free » au fichier « /etc/apt/sources.list ».%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo sed --in-place 's/main non-free-firmware$/main non-free-firmware contrib non-free/g' /etc/apt/sources.list
  check $?
}

update_apt() {
  echo
  printf '%sMise à jour de la liste des paquets.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo apt update
  check $?
}

upgrade_apt() {
  echo
  printf '%sInstallation d’éventuelles mises à jour des paquets.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo apt upgrade
  check $?
}

install_cutom_pkgs() {
  echo
  printf '%sInstallation d’un choix personnel de paquets.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  pkgs="\
alacritty \
anacron \
arc \
arj \
atool \
bash-completion \
bat \
bc \
bfs \
blueman \
bluez \
bluez-tools \
brightnessctl \
bsdutils \
bzip2 \
calibre \
cargo \
catdoc \
chafa \
chromium \
chromium-l10n \
clinfo \
cliphist \
cmake \
colordiff \
colortest-python \
cpio \
curl \
dbus \
dconf-editor \
dex \
dictionaries-common \
diffutils \
dmidecode \
docx2txt \
du-dust \
duf \
eject \
e2fsprogs \
exfatprogs \
exif \
libimage-exiftool-perl \
eza \
fastfetch \
fd-find \
fdisk \
ffmpegthumbnailer \
firefox-esr \
firefox-esr-l10n-fr \
foot \
fzf \
galternatives \
gcal \
gh \
gnome-characters \
gnome-epub-thumbnailer \
golang \
gparted \
grim \
gucharmap \
gvfs \
gvfs-backends \
gvfs-fuse \
gzip \
htop \
hunspell \
hyperfine \
hyphen-fr \
imagemagick \
info \
inxi \
jekyll \
jq \
kanshi \
keepassxc \
kid3-qt \
kitty \
kitty-terminfo \
labwc \
lf \
libcdio-utils \
libcpanel-json-xs-perl \
libdvd-pkg \
libfuse2t64 \
libglib2.0-bin \
libnotify-bin \
libnotify-dev \
libpixman-1-dev \
libreoffice-calc \
libreoffice-grammalecte \
libreoffice-help-fr \
libreoffice-java-common \
libreoffice-l10n-fr \
libreoffice-qt6 \
libreoffice-writer \
libxml-dumper-perl \
lxpolkit \
lzip \
lzop \
mako-notifier \
mediainfo \
mesa-utils \
meson \
micro \
mintstick \
moreutils \
mousepad \
mpv \
neovim \
network-manager \
nm-connection-editor \
nomarch \
pandoc \
parallel \
pdfarranger \
plocate \
poppler-utils \
qbittorrent \
qimgv \
qt5ct \
qt6ct \
rar \
rclone \
regionset \
rfkill \
ripgrep \
rpm \
rsync \
ruby-jekyll-paginate \
ruby-jekyll-sitemap \
screenruler \
sd \
sensible-utils \
shellcheck \
shfmt \
slurp \
smartmontools \
swayidle \
tar \
tealdeer \
thunar \
thunar-archive-plugin \
thunar-gtkhash \
thunar-media-tags-plugin \
thunar-volman \
thunderbird \
thunderbird-l10n-fr \
timeshift \
transmission-cli \
trash-cli \
tree \
udisks2 \
unace \
unalz \
unrar \
upower \
vainfo \
virt-manager \
vlc \
vlc-plugin-pipewire \
vulkan-tools \
wayland-utils \
wev \
wdisplays \
wget \
wl-clipboard \
wlopm \
wlr-randr \
wlrctl \
xz-utils \
yt-dlp \
zathura \
zathura-pdf-poppler \
zathura-cb \
zathura-djvu \
zathura-ps \
wayland-protocols \
libwayland-client++1 \
libxkbcommon-dev \
libcairo2-dev \
libpango1.0-dev \
libpugixml-dev \
libwayland-client-extra++1 \
libwayland-dev
pipewire-audio \
wireplumber \
xfce4-appfinder \
odt2txt \
catfish \
pavucontrol-qt \
pavucontrol-qt-l10n \
pulsemixer \
cmus \
quodlibet \
ods2tsv"
  # fontforge \
  # python3-fontforge"
  # wmctrl \
  # abcde \
  # archivemount \
  # atril \
  # featherpad \
  # network-manager-gnome \
  # numlockx \
  # parted \
  # partitionmanager \
  # qpdf \
  # sxhkd \
  # synaptic \
  # syncthing \
  # transmission-qt \
  # xarchiver \
  # xcalib \
  # xcape \
  # xclip \
  # xdotool \
  # xfce4 \
  # xfce4-notifyd \
  # xfce4-panel \
  # xfce4-power-manager \
  # xfce4-pulseaudio-plugin \
  # xfce4-screenshooter \
  # xfce4-session \
  # xfce4-settings \
  # xfce4-terminal \
  # xfce4-xkb-plugin \
  # xfconf \
  # xfwm4 \

  # shellcheck disable=SC2086 # On veut séparer les paquets.
  install $pkgs
  check $?
}

config_libdvd() {
  echo
  printf '%sConfiguration de libdvd.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo dpkg-reconfigure libdvd-pkg
  check $?
}

install_extrepo() {
  # https://linuxiac.com/how-to-use-extrepo-in-debian-to-manage-third-party-repositories/
  
  echo
  printf '%sInstallation et configuration d’« extrepo », logiciel permettant d’ajouter de manière sûre des dépôts externes.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo apt install extrepo
  sudo sed --in-place 's/^# - contrib/- contrib/' /etc/extrepo/config.yaml
  sudo sed --in-place 's/^# - non-free/- non-free/' /etc/extrepo/config.yaml
  check $?
}

create_dirs() {
  echo
  printf '%sCréation de répertoires nécessaires.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  userdirs="\
$HOME/Projets
$HOME/bin
$HOME/.local/bin
$HOME/.local/share
$HOME/.local/state
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

export_env_vars() {
  echo
  printf '%sAjouts de variables d’environnement utiles.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

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

install_dra() {
  install_name dra
  read -r answer
  [ "$answer" = 'n' ] && return

  curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/devmatteini/dra/refs/heads/main/install.sh | bash -s
  chmod +x ./dra
  sudo mv --force ./dra /usr/local/bin/

  if [ "$SHELL" = 'bash' ]; then
    dra completion bash > ./dra
    sudo mv --force ./dra /usr/local/share/bash-completion/completions/
  fi

  check $?
}

install_bashmount() {
  install_name bashmount
  read -r answer
  [ "$answer" = 'n' ] && return

  curl --remote-name https://raw.githubusercontent.com/jamielinux/bashmount/master/bashmount
  chmod +x ./bashmount
  sudo mv --force ./bashmount /usr/local/bin/
  curl --remote-name https://raw.githubusercontent.com/jamielinux/bashmount/refs/heads/master/bashmount.1
  sudo mv --force ./bashmount.1 /usr/local/share/man/man1/
  check $?
}

install_pastel() {
  install_name pastel
  read -r answer
  [ "$answer" = 'n' ] && return

  dra download --select "pastel_{tag}_amd64.deb" sharkdp/pastel
  install ./pastel*.deb
  rm ./pastel*.deb
  check $?
}

install_uni() {
  install_name uni
  read -r answer
  [ "$answer" = 'n' ] && return

  dra download --select "uni-v{tag}-linux-amd64.gz" arp242/uni
  atool --extract uni*.gz
  rm --force uni*.gz
  sudo mv --force uni-v*-linux-amd64 /usr/local/bin/uni
  sudo chmod +x /usr/local/bin/uni
  check $?
}

install_ouch() {
  install_name ouch
  read -r answer
  [ "$answer" = 'n' ] && return

  dra download --select "ouch-x86_64-unknown-linux-gnu.tar.gz" ouch-org/ouch
  atool --extract ouch-x86_64-unknown-linux-gnu.tar.gz
  sudo mv --force ./ouch-x86_64-unknown-linux-gnu/ouch /usr/local/bin/
  sudo chmod +x /usr/local/bin/ouch
  sudo mv --force ./ouch-x86_64-unknown-linux-gnu/completions/ouch.bash /usr/local/share/bash-completion/completions/
  sudo mv --force ./ouch-x86_64-unknown-linux-gnu/man/* /usr/local/share/man/man1/
  rm -rf ./ouch-*
  check $?
}

install_moar() {
  install_name moar
  read -r answer
  [ "$answer" = 'n' ] && return

  dra download --select "moar-v{tag}-linux-amd64" walles/moar
  sudo mv --force moar-*-*-* /usr/local/bin/moar
  sudo chmod +x /usr/local/bin/moar
  curl --remote-name https://raw.githubusercontent.com/walles/moar/refs/heads/master/moar.1
  sudo mv --force ./moar.1 /usr/local/share/man/man1/
  check $?
}

install_fend() {
  install_name fend
  read -r answer
  [ "$answer" = 'n' ] && return

  dra download --select "fend-{tag}-linux-x86_64-gnu.zip" printfn/fend
  atool --extract fend-*-linux-x86_64-gnu.zip
  sudo mv --force fend /usr/local/bin/
  sudo chmod +x /usr/local/bin/fend
  dra download --select "fend.1" printfn/fend
  sudo mv --force ./fend.1 /usr/local/share/man/man1/
  rm ./fend-*
  check $?
}

install_diskus() {
  install_name diskus
  read -r answer
  [ "$answer" = 'n' ] && return

  dra download --select "diskus_{tag}_amd64.deb" sharkdp/diskus
  install ./diskus*.deb
  sudo rm ./diskus*.deb
  check $?
}

install_flacon() {
  install_name flacon
  read -r answer
  [ "$answer" = 'n' ] && return

  # Les AppImages semblent mal fonctionner sous wayland.
  dra download --select "flacon-{tag}-x86_64.AppImage" flacon/flacon
  sudo mv flacon-*-*.AppImage /usr/local/bin/
  sudo chmod +x /usr/local/bin/flacon-*-*.AppImage
  check $?
}

install_advcpmv() {
  echo
  printf '%sInstallation de advcpmv%s (peut prendre quelques minutes). ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

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

install_massren() {
  install_name massren
  read -r answer
  [ "$answer" = 'n' ] && return

  if ! command -v go > /dev/null; then
    install golang
  fi

  go install github.com/laurent22/massren@latest
  sudo cp --force "$GOPATH/bin/massren" /usr/local/bin/
  check $?
}

# J'ai besoin d'une version >= 0.6, or au 14/03/2025, debian testing n'a encore que 0.5.
# Pas de bogue si j'utilise une version < 0.6, l'option de contrôle de la longueur des lignes de prévisualisation est simplement ignorée.
install_cliphist() {
  install_name cliphist
  read -r answer
  [ "$answer" = 'n' ] && return

  if ! command -v go > /dev/null; then
    install golang
  fi

  go install go.senan.xyz/cliphist@latest
  sudo cp --force "$GOPATH/bin/cliphist" /usr/local/bin/
  check $?
}

install_wl_gammarelay_rs() {
  echo
  printf '%sInstallation de wl-gammarelay-rs%s (peut prendre quelques minutes). ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  if ! command -v cargo > /dev/null; then
    install cargo
  fi

  cargo install wl-gammarelay-rs --locked
  sudo cp --force "$CARGO_HOME/bin/wl-gammarelay-rs" /usr/local/bin/
  sudo chmod +x /usr/local/bin/wl-gammarelay-rs
  check $?
}

install_vscodium() {
  install_name VSCodium
  read -r answer
  [ "$answer" = 'n' ] && return

  # wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
  #   | gpg --dearmor \
  #   | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

  # echo 'deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg] https://download.vscodium.com/debs vscodium main' \
  #   | sudo tee /etc/apt/sources.list.d/vscodium.list

  sudo extrepo enable vscodium
  sudo apt update && sudo apt install codium
  check $?
}

install_batsignal() {
  install_name batsignal
  read -r answer
  [ "$answer" = 'n' ] && return

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

# Ces logiciels s'installent dans /usr et non dans /usr/local. Malheureusement leurs makefiles ne respectent pas l'argument `--prefix /usr/local` qui pourrait être passé à `cmake`.
install_hyprpicker() {
  install_name hyprpicker
  read -r answer
  [ "$answer" = 'n' ] && return

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

install_timemachine() {
  install_name timemachine
  read -r answer
  [ "$answer" = 'n' ] && return

  curl --remote-name https://raw.githubusercontent.com/cytopia/linux-timemachine/refs/heads/master/timemachine
  chmod +x ./timemachine
  sudo mv --force ./timemachine /usr/local/bin/
  check $?
}

install_datedirclean() {
  install_name datedirclean.sh
  read -r answer
  [ "$answer" = 'n' ] && return

  curl --remote-name https://raw.githubusercontent.com/meersjo/toolkit/refs/heads/master/various/datedirclean.sh
  chmod +x ./datedirclean.sh
  sudo mv --force ./datedirclean.sh /usr/local/bin/
  check $?
}

install_labwc_gtktheme() {
  install_name labwc-gtktheme
  read -r answer
  [ "$answer" = 'n' ] && return

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

install_homebrew() {
  install_name homebrew
  read -r answer
  [ "$answer" = 'n' ] && return

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  check $?
}

install_eid_belgium() {
  install_name 'eID Belgium'
  read -r answer
  [ "$answer" = 'n' ] && return

  curl --remote-name https://eid.belgium.be/sites/default/files/software/eid-archive_latest.deb
  install ./eid-archive_latest.deb
  sudo apt update && install eid-viewer eid-mw
  rm ./eid-archive_latest.deb
  check $?
}

install_signal() {
  install_name 'Signal Desktop'
  read -r answer
  [ "$answer" = 'n' ] && return

  # wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
  # # shellcheck disable=SC2002 # Je prends cette ligne du site web: https://signal.org/fr/download/linux/.
  # cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
  # echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' \
  #   | sudo tee /etc/apt/sources.list.d/signal-xenial.list

  sudo extrepo enable signal
  sudo apt update && sudo apt install signal-desktop
  check $?
}

install_emailbook() {
  if command -v aerc > /dev/null; then
    install_name 'emailbook (pour aerc)'
    read -r answer
    [ "$answer" = 'n' ] && return

    curl --remote-name https://git.sr.ht/~maxgyver83/emailbook/blob/main/emailbook
    chmod +X ./emailbook
    sudo mv ./emailbook /usr/local/bin/
    check $?
  fi
}

correct_perms() {
  echo
  printf '%sCorrection des permissions des répertoires du système.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo chmod 755 /usr/local/bin/*
  sudo chown root:root /usr/local/bin/*
  check $?
}

config_logind() {
  echo
  printf '%sConfiguration de « /etc/systemd/logind.conf ».%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo sed --in-place 's/^#HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
  sudo sed --in-place 's/^#IdleAction=.*/IdleAction=suspend/' /etc/systemd/logind.conf
  sudo sed --in-place 's/^#IdleActionSec=.*/IdleActionSec=4min/' /etc/systemd/logind.conf
  check $?
}

config_grub() {
  echo
  printf '%sConfiguration de grub.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo sed --in-place 's/GRUB_TIMEOUT=./GRUB_TIMEOUT=2/' "/etc/default/grub"
  sudo update-grub
  check $?
}

make_symlinks() {
  echo
  printf '%sÉtablissement de liens symboliques de batcat et fdfind vers bat et fd.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo ln -s /usr/bin/batcat /usr/local/bin/bat
  sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
  check $?
}

create_root_passwd() {
  echo
  printf '%sCréation du mot de passe du compte root.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo passwd root
  check $?
}

config_apt_colors() {
  echo
  printf '%sConfiguration des couleurs d’apt.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  apt_conf_dir='/etc/apt/apt.conf.d'
  apt_color_conf='21-colors.conf'
  test ! -d "$apt_conf_dir" && sudo mkdir --parents "$apt_conf_dir"
  echo 'APT::Color::Action::Upgrade "blue";' | sudo tee "$apt_conf_dir/$apt_color_conf"
  check $?
}

add_rescue_user() {
  user_name=toto

  echo
  printf '%sAjout d’un utilisateur de secours: %s.%s ' "${bold}" "$user_name" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  # `adduser` est une commande spécifique à Debian et à ses dérivées.
  sudo adduser "$user_name"
  check $?
}

config_custom_desktop_files() {
  echo
  printf '%sConfiguration d’un fichier desktop personnalisé pour quelques applications.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

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

decrease_systemd_timeout() {
  echo
  printf '%sDiminution drastique du temps d’attente qu’un job se termine à la déconnexion.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo mkdir --parents /etc/systemd/logind.conf.d/
  printf '# Fichier créé par le script %s.\n\nDefaultTimeoutStopSec=5s\nDefaultTimeoutAbortSec=10s' "$(basename "$0")" \
    | sudo tee /etc/systemd/logind.conf.d/timeoutstop.conf
  sudo systemctl daemon-reload
  check $?
}

copy_data() {
  echo
  printf '%sCopie de données personnelles d’un périphérique de stockage externe.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  if ! command -v bashmount > /dev/null; then
    printf '%sbashmount n’est pas installé. Ce logiciel est nécessaire à cette étape. Abandon.%s ' "${bold}" "${reset}"
    return
  fi

  echo
  printf '%sInsérez maintenant le périphérique de stockage externe contenant les données à copier, puis pressez « entrée ».%s\nLe logiciel bashmount sera exécuté, vous permettant de monter le périphérique inséré. ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

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

    if ! command -v cpg > /dev/null; then
      sudo cp --strip-trailing-slashes --reflink=auto --no-preserve=mode,ownership --recursive --force -- "$my_path/usr/local/share/pixmaps/." /usr/local/share/pixmaps/
    else
      sudo cpg --strip-trailing-slashes --reflink=auto --no-preserve=mode,ownership --recursive --force --progress-bar -- "$my_path/usr/local/share/pixmaps/." /usr/local/share/pixmaps/
    fi
  fi

  # if [ -d "$my_path/usr/local/share/applications" ] && [ "$(ls -A "$my_path/usr/local/share/applications")" ]; then
  #   sudo mkdir --parents /usr/local/share/applications

  #   if ! command -v cpg >/dev/null; then
  #     sudo cp --strip-trailing-slashes --reflink=auto --no-preserve=mode,ownership --recursive --force -- "$my_path"/usr/local/share/applications/*.desktop /usr/local/share/applications/
  #   else
  #     sudo cpg --strip-trailing-slashes --reflink=auto --no-preserve=mode,ownership --recursive --force --progress-bar -- "$my_path"/usr/local/share/applications/*.desktop /usr/local/share/applications/
  #   fi
  # fi

  check $?

  # echo
  # echo "Copie du contenu personnalisé de « ${my_path}/etc/ » dans « /etc/ »."
  # echo

  # if [ -e "$my_path/etc/issuefg" ]; then
  #   if ! command -v cpg >/dev/null; then
  #     sudo cp --strip-trailing-slashes --reflink=auto --no-preserve=mode,ownership --recursive --force -- "$my_path/etc/issuefg" /etc/
  #   else
  #     sudo cpg --strip-trailing-slashes --reflink=auto --no-preserve=mode,ownership --recursive --force --progress-bar -- "$my_path/etc/issuefg" /etc/
  #   fi
  # fi

  # check $?
}

make_exec() {
  echo
  printf '%sCorrection des permissions des répertoires « bin » personnels.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  # Uniquement si ces répertoires ne sont pas vides.
  if [ "$(ls -A ~/bin)" ]; then
    chmod +x ~/bin/*
  fi

  if [ "$(ls -A ~/.local/bin)" ]; then
    chmod +x ~/.local/bin/*
  fi

  check $?
}

config_keyboard() {
  if [ -e "${XDG_CONFIG_HOME:-$HOME/.config}/xkb/symbols/custom" ]; then
    echo
    printf '%sConfiguration du clavier personnalisé « custom ».%s ' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

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
XKBOPTIONS="terminate:ctrl_alt_bksp,compose:ins,nbsp:level3n,kpdl:comma,numpad:mac"
BACKSPACE="guess"' \
      | sudo tee /etc/default/keyboard
    check $?

    echo
    printf '%sInversion des touches Home/End et Page Up/Down.%s ' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    echo 'XKBVARIANT="fg_invert_home_end_with_pageup_pagedown"' \
      | sudo tee --append /etc/default/keyboard
    check $?

    echo
    printf '%sSynchronisation des changements avec la console.%s ' "${bold}" "${reset}"
    sudo setupcon
    check $?
  fi
}

config_lf() {
  if command -v lf > /dev/null; then
    echo
    printf '%sConfiguration de lf.%s ' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    mkdir --parents "${XDG_DATA_HOME:-$HOME/.local/share}/lf"
    ln -s "${XDG_CONFIG_HOME:-$HOME/.config}/lf/marks" "${XDG_DATA_HOME:-$HOME/.local/share}/lf/"

    # Rendre exécutable le script de nettoyage des images affichées par lf dans kitty.
    chmod +x "${XDG_CONFIG_HOME:-$HOME/.config}/lf/lf_kitty_clean"
    check $?
  fi
}

correct_ssh_perms() {
  if [ -d "$HOME/.ssh/" ] && [ "$(ls -A "$HOME/.ssh/")" ]; then
    echo
    printf '%sCorrection des permissions de mes clés ssh.%s ' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    chmod 600 ~/.ssh/*
    check $?
  fi
}

config_default_editor() {
  echo
  printf '%sConfiguration de l’éditeur de texte par défaut.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo update-alternatives --config editor
  check $?
}

## Désactiver certains services inutiles (il peut aussi être nécessaires de les masquer, pour empêcher que d'autres processus ne les relancent).
config_systemd_services() {
  echo
  printf '%sConfiguration de services de systemd.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  systemctl --user disable gvfs-goa-volume-monitor.service
  systemctl --user mask gvfs-goa-volume-monitor.service
  sudo systemctl disable ModemManager.service
  sudo systemctl disable cups.service
  sudo systemctl disable cups-browsed.service
  sudo systemctl disable accounts-daemon
  sudo systemctl mask accounts-daemon
  check $?
}

config_thunar() {
  if command -v thunar > /dev/null; then
    echo
    printf '%sConfiguration de Thunar.%s ' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    thunar -q
    # toujours afficher le chemin complet dans la barre de titre de Thunar
    # pour Thunar 4.18 (mais mieux vaut peut-être l'option qui affiche le chemin complet dans le titre de l'onglet; ce qui me permet d'activer l'option de cacher la barre de titre des fenêtres maximisées)
    xfconf-query --channel thunar --property /misc-full-path-in-window-title --create --type bool --set true
    # afficher les onglets même quand un seul est ouvert; utile si j'active l'option qui masque le titre des fenêtres maximisées
    xfconf-query --channel thunar --property /misc-always-show-tabs --create --type bool --set true
    check $?
  fi
}

config_xfce_panel() {
  if command -v xfce4-panel > /dev/null; then
    echo
    printf '%sConfiguration de xfce4-panel.%s ' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    # Désactiver l'animation de masquage automatique du tableau de bord d'Xfce.
    xfconf-query -n -c xfce4-panel -p /panels/panel-1/popdown-speed -t int -s 0
    # Les délais de masquage et la hauteur résiduelle du tableau de bord peuvent être configurés avec du css.
    # Voir https://docs.xfce.org/xfce/xfce4-panel/preferences.
    check $?
  fi
}

config_xfce_session() {
  if command -v xfce4-session > /dev/null; then
    echo
    printf '%sConfiguration de xfce4-session.%s ' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    # Désactiver le lancement automatique de gpg et ssh.
    xfconf-query -c xfce4-session -p /startup/ssh-agent/enabled -n -t bool -s false
    xfconf-query -c xfce4-session -p /startup/gpg-agent/enabled -n -t bool -s false
    check $?
  fi
}

config_documents_hourly_backup() {
  if command -v timemachine > /dev/null \
    && command -v datedirclean.sh > /dev/null \
    && command -v sauvegarde_locale_timemachine_Documents.sh > /dev/null; then
    echo
    printf '%sConfiguration de la sauvegarde horaire des documents cruciaux.%s ' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

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
  fi
}

config_mime() {
  if command -v fset-default-app-for-mime-category.sh > /dev/null; then
    echo
    printf '%sConfiguration de l’association d’une application à toute une catégorie de types mime.%s ' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    command -v codium > /dev/null && fset-default-app-for-mime-category.sh text codium
    command -v qimgv > /dev/null && fset-default-app-for-mime-category.sh image qimgv
    command -v vlc > /dev/null && fset-default-app-for-mime-category.sh audio vlc
    command -v mpv > /dev/null && fset-default-app-for-mime-category.sh video mpv
    check $?
  fi
}

config_tty1_nameless_login() {
  echo
  printf '%sConfiguration de la connexion sans nom d’utilisateur sur la tty1.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

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
    | sudo tee "/etc/systemd/system/getty@tty1.service.d/override.conf"

  check $?
}

config_shell_options_and_aliases() {
  echo
  printf '%sConfiguration des options et alias par défaut du shell.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

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

create_dollar_script() {
  echo
  printf '%sCréer dans /usr/local/bin un script permettant d’exécuter une ligne commençant par un dollar.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  printf '#!/bin/sh\neval "$*"' | sudo tee /usr/local/bin/$
  sudo chmod +x /usr/local/bin/$
  check $?
}

forward_journald_to_tty12() {
  # Cf. https://wiki.archlinux.org/title/Systemd/Journal#Forward_journald_to_/dev/tty12.
  echo
  printf '%sAffichage de journald sur la tty12.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo mkdir --parents /etc/systemd/journald.conf.d
  echo '[Journal]
ForwardToConsole=yes
TTYPath=/dev/tty12' | sudo tee /etc/systemd/journald.conf.d/fw-tty12.conf
  sudo systemctl restart systemd-journald.service
  check $?
}

build_bat_cache() {
  # La construction du cache est nécessaire pour utiliser un thème personnalisé.
  if command -v bat > /dev/null; then
    echo
    printf '%sConstruction du cache de bat.%s ' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    bat cache --build
    check $?
  fi
}

update_locate_db() {
  echo
  printf '%sCréation de la base de données générale de locate.%s ' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo updatedb
  check $?
}

show_what_to_do_manually() {
  echo
  echo "À FAIRE MANUELLEMENT après redémarrage

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

echo
echo '##########################################'
echo "# ${bold}SCRIPT DE POST-INSTALLATION DE DEBIAN.${reset} #"
echo '##########################################'
echo
echo "Pressez « ${bold}entrée${reset} » pour confirmer chaque étape, « ${bold}n${reset} » puis « ${bold}entrée${reset} » pour la passer, ou « ${bold}ctrl-c${reset} » pour quitter."

config_console
activate_tty2
backup_apt_sourceslist
config_apt_sourceslist
update_apt
upgrade_apt
install_cutom_pkgs
config_libdvd
create_dirs
export_env_vars

echo
echo '#######################################'
echo "# ${bold}INSTALLATION DE LOGICIELS HORS APT.${reset} #"
echo '#######################################'

install_dra
install_bashmount
install_pastel
install_uni
install_ouch
install_moar
install_fend
install_diskus
# install_flacon
install_advcpmv
install_massren
install_cliphist
install_wl_gammarelay_rs
install_vscodium
install_batsignal
install_hyprpicker
install_timemachine
install_datedirclean
install_labwc_gtktheme
install_homebrew
install_eid_belgium
install_signal
install_emailbook

echo
echo '############################'
echo "# ${bold}CONFIGURATION DU SYSTÈME.${reset} #"
echo '############################'

config_logind
config_grub
make_symlinks
create_root_passwd
config_apt_colors
add_rescue_user
config_shell_options_and_aliases
create_dollar_script
forward_journald_to_tty12
decrease_systemd_timeout

echo
echo '###########################################'
echo "# ${bold}CONFIGURATION DES DONNÉES PERSONNELLES.${reset} #"
echo '###########################################'

copy_data
make_exec
config_keyboard
config_lf
correct_ssh_perms
config_default_editor
config_systemd_services
config_thunar
config_xfce_panel
config_xfce_session
config_documents_hourly_backup
config_custom_desktop_files
config_mime
config_tty1_nameless_login
build_bat_cache
correct_perms
update_locate_db

echo
echo '########'
echo "# ${bold}FIN.${reset} #"
echo '########'
echo
echo "${bold}Il est conseillé de redémarrer maintenant.${reset}"

show_what_to_do_manually
