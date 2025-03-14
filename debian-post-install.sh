#!/bin/sh
# shellcheck disable=SC2034

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
# chmod +x ./debian-post-install.sh
# sh ./debian-post-install.sh

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
  sudo apt install
}

install_name() {
  echo
  printf '%sInstallation de %s.%s' "${bold}" "$1" "${reset}"
}

echo '##########################################'
echo "${bold}# SCRIPT DE POST-INSTALLATION DE DEBIAN. #${reset}"
echo '##########################################'
echo
echo "Pressez « ${bold}entrée${reset} » pour confirmer chaque étape, « ${bold}n puis entrée${reset} » pour la passer, ou « ${bold}ctrl-c${reset} » pour quitter."

config_console() {
  echo
  printf '%sConfiguration interactive de la console.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo dpkg-reconfigure console-setup
  check $?
}

backup_apt_sourceslist() {
  # Si la copie existe déjà, on ne l'écrase pas.
  if ! [ -e /etc/apt/sources.list.bak ]; then
    echo
    printf '%sCréation d’une copie de sauvegarde du fichier « /etc/apt/sources.list ».%s' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    check $?
  fi
}

config_apt_sourceslist() {
  echo
  printf '%sAjout des composants « contrib » et « non-free » au fichier « /etc/apt/sources.list ».%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo sed --in-place 's/main non-free-firmware$/main non-free-firmware contrib non-free/g' /etc/apt/sources.list
  check $?
}

update_apt() {
  echo
  printf '%sMise à jour de la liste des paquets.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo apt update
  check $?
}

upgrade_apt() {
  echo
  printf '%sInstallation d’éventuelles mises à jour des paquets.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo apt upgrade
  check $?
}

install_cutom_pkgs() {
  echo
  printf '%sInstallation d’un choix personnel de paquets.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  pkgs="\
alacritty \
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
nomarch \
odt2txt \
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
wayland-protocols \
libwayland-client++1 \
libxkbcommon-dev \
libcairo2-dev \
libpango1.0-dev \
libpugixml-dev \
libwayland-client-extra++1 \
libwayland-dev"
  # wmctrl \
  # abcde \
  # archivemount \
  # atril \
  # catfish \
  # featherpad \
  # network-manager-gnome \
  # numlockx \
  # parted \
  # partitionmanager \
  # pavucontrol-qt \
  # pavucontrol-qt-l10n \
  # qpdf \
  # quodlibet \
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
  # xfce4-appfinder \
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
  printf '%sConfiguration de libdvd.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo dpkg-reconfigure libdvd-pkg
  check $?
}

create_dirs() {
  echo
  printf '%sCréation de répertoires nécessaires.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  userdirs="\
$HOME/Projets
$HOME/bin
$HOME/.local/bin
$HOME/.local/share
$HOME/.local/state
$HOME/.config
$HOME/.cache"

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

  check $?
}

export_env_vars() {
  echo
  printf '%sAjouts de variables d’environnement utiles.%s' "${bold}" "${reset}"
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

echo '#######################################'
printf '%s# INSTALLATION DE LOGICIELS HORS APT. #%s' "${bold}" "${reset}"
echo '#######################################'

install_dra() {
  install_name dra
  read -r answer
  [ "$answer" = 'n' ] && return

  curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/devmatteini/dra/refs/heads/main/install.sh | bash -s
  chmod +x ./dra
  sudo mv --force ./dra /usr/local/bin/

  if [ "$SHELL" = 'bash' ]; then
    dra completion bash >./dra
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
  printf '%sInstallation de advcpmv%s (peut prendre quelques minutes).' "${bold}" "${reset}"
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

  if ! command -v go >/dev/null; then
    install golang
  fi

  go install github.com/laurent22/massren@latest
  sudo cp --force "$GOPATH/bin/massren" /usr/local/bin/
  check $?
}

install_wl_gammarelay_rs() {
  echo
  printf '%sInstallation de wl-gammarelay-rs%s (peut prendre quelques minutes).' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  if ! command -v cargo >/dev/null; then
    install cargo
  fi

  cargo install wl-gammarelay-rs --locked
  sudo cp --force "$CARGO_HOME/bin/wl-gammarelay-rs" /usr/local/bin/
  sudo chmod +x /usr/local/bin/wl-gammarelay-rs
  check $?
}

install_wlinhibit() {
  install_name wlinhibit
  read -r answer
  [ "$answer" = 'n' ] && return

  dra download --select "x86_64-unknown-linux-gnu" 0x5a4/wlinhibit
  sudo mv --force ./"x86_64-unknown-linux-gnu" /usr/local/bin/wlinhibit
  sudo chmod +x /usr/local/bin/wlinhibit
  check $?
}

install_vscodium() {
  install_name VSCodium
  read -r answer
  [ "$answer" = 'n' ] && return

  wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

  echo 'deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg] https://download.vscodium.com/debs vscodium main' \
    | sudo tee /etc/apt/sources.list.d/vscodium.list

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
  cmake --build ./build --config Release --target all -j"$(nproc 2>/dev/null || getconf NPROCESSORS_CONF)"
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
  cmake --build ./build --config Release --target hyprpicker -j"$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
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
  labwc-gtktheme.py
  check $?
}

correct_perms() {
  echo
  printf '%sCorrection des permissions des répertoires du système.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo chmod 755 /usr/local/bin/*
  sudo chown root:root /usr/local/bin/*
  check $?
}

config_logind() {
  echo
  printf '%sConfiguration de « /etc/systemd/logind.conf ».%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo sed --in-place 's/^#HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
  sudo sed --in-place 's/^#IdleAction=.*/IdleAction=suspend/' /etc/systemd/logind.conf
  sudo sed --in-place 's/^#IdleActionSec=.*/IdleActionSec=4min/' /etc/systemd/logind.conf
  check $?
}

config_grub() {
  echo
  printf '%sConfiguration de grub.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo sed --in-place 's/GRUB_TIMEOUT=./GRUB_TIMEOUT=2/' "/etc/default/grub"
  sudo update-grub
  check $?
}

make_symlinks() {
  echo
  printf '%sÉtablissement de liens symboliques de batcat et fdfind vers bat et fd.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo ln -s /usr/bin/batcat /usr/local/bin/bat
  sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
  check $?
}

create_root_passwd() {
  echo
  printf '%sCréation du mot de passe du compte root.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo passwd root
  check $?
}

config_apt_colors() {
  echo
  printf '%sConfiguration des couleurs d’apt.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  apt_conf_dir='/etc/apt/apt.conf.d'
  apt_color_conf='21-colors.conf'
  test ! -d "$apt_conf_dir" && sudo mkdir --parents "$apt_conf_dir"
  sudo echo 'APT::Color::Action::Upgrade "blue";' | sudo tee "$apt_conf_dir/$apt_color_conf"
  check $?
}

add_rescue_user() {
  echo
  printf '%sAjout d’un utilisateur de secours: toto.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo useradd toto
  check $?
}

echo '######################################'
echo "${bold}# CONFIGURATION DES DONNÉES PRIVÉES. #${reset}"
echo '######################################'

copy_data() {
  disque=MINI

  # MAINTENANT, il faut insérer un périphérique de stockage externe sur lequel se trouve mes données à copier, le monter, procéder à la copie.
  echo
  printf '%sInsérez maintenant la clé usb « %s », contenant les données personnelles à copier sur cet ordinateur, puis pressez « entrée ».%s bashmount sera exécuté, vous permettant de monter la clé insérée.' "${bold}" "$disque" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  bashmount
  montage="$(findmnt --real --noheadings --output=TARGET LABEL=${disque})"

  if [ ! -d "${montage}" ]; then
    echo
    echo "La clé usb « $disque » n’est pas montée. Abandon."

    exit 1
  fi

  echo
  printf '%sSaisissez maintenant le nom exact — sans chemin — du répertoire de %s où se trouve le dossier HOME à copier sur cet ordinateur:%s ' "${bold}" "$disque" "${reset}"
  read -r rep

  cpg --strip-trailing-slashes --reflink=auto --no-preserve=mode,ownership --progress-bar --recursive --force -- "$montage/Sauvegarde/$rep/home/$USER/." "$HOME"/
  check $?
}

config_keyboard() {
  if [ -e "$XDG_CONFIG_HOME/xkb/symbols/custom" ]; then
    echo
    printf '%sÉtablissement d’un lien symbolique entre mon clavier personnalisé et le clavier « custom » du système.%s' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    sudo ln -s "$XDG_CONFIG_HOME/xkb/symbols/custom" "/usr/share/X11/xkb/rules/"
    check $?

    echo
    printf '%sConfiguration du clavier: choisir le clavier « custom ».%s' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    # D'abord ceci, parce que la clavier de la console est configuré aussi?
    sudo dpkg-reconfigure keyboard-configuration
    check $?

    echo
    printf '%sAjout d’options à la configuration du clavier.%s' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    # sudo sed --in-place 's///' /etc/default/keyboard
    # sudo sed --in-place 's///' /etc/default/keyboard

    sudo echo '# KEYBOARD CONFIGURATION FILE
# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="custom"
XKBOPTIONS="compose:ins,nbsp:level3n,kpdl:comma"
BACKSPACE="guess"
XKBVARIANT="fg_invert_home_end_with_pageup_pagedown,"' \
      | sudo tee /etc/default/keyboard

    check $?
  fi
}

config_lf() {
  echo
  printf '%sConfiguration de lf.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  mkdir --parents "$XDG_DATA_HOME/lf"
  ln -s "$XDG_CONFIG_HOME/lf/marks" "$XDG_DATA_HOME/lf/"

  # Rendre exécutable le script de nettoyage des images affichées par lf dans kitty.
  chmod +x "$XDG_CONFIG_HOME/lf/lf_kitty_clean"
  check $?
}

correct_ssh_perms() {
  if [ -d "$HOME/.ssh/" ]; then
    echo
    printf '%sCorrection des permissions de mes clés ssh.%s' "${bold}" "${reset}"
    read -r answer
    [ "$answer" = 'n' ] && return

    chmod 600 ~/.ssh/*
    check $?
  fi
}

config_default_editor() {
  echo
  printf '%sConfiguration de l’éditeur de texte par défaut.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  sudo update-alternatives --config editor
  check $?
}

## Désactiver certains services inutiles (il peut aussi être nécessaires de les masquer, pour empêcher que d'autres processus ne les lancent).
config_systemd_services() {
  echo
  printf '%sConfiguration de services de systemd.%s' "${bold}" "${reset}"
  read -r answer
  [ "$answer" = 'n' ] && return

  systemctl --user disable gvfs-goa-volume-monitor.service
  systemctl --user mask gvfs-goa-volume-monitor.service
  sudo systemctl disable ModemManager.service
  sudo systemctl disable cups.service
  sudo systemctl disable cups-browsed.service
  sudo systemctl disable accounts-daemon
  sudo systemctl mask accounts-daemon
}

# Exécution des fonctions.
config_console
backup_apt_sourceslist
config_apt_sourceslist
update_apt
upgrade_apt
install_cutom_pkgs
config_libdvd
create_dirs
export_env_vars
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
install_wl_gammarelay_rs
install_wlinhibit
install_vscodium
install_batsignal
install_hyprpicker
install_timemachine
install_datedirclean
install_labwc_gtktheme
correct_perms
config_logind
config_grub
make_symlinks
create_root_passwd
config_apt_colors
add_rescue_user
copy_data
config_keyboard
config_lf
correct_ssh_perms
config_default_editor
# config_systemd_services
