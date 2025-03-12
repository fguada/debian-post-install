#!/bin/sh

# set -o errexit
# set -o nounset
# set -o noglob # "Disable pathname expansion"
# exec 2>|"$HOME/log.txt" # pour envoyer la sortie de xtrace dans un fichier
# set -o xtrace
# IFS="
# "
# IFS="$(printf '\n\t')" # par défaut: ' \n\t'

# À faire AVANT l'exécution de ce script:
# sudo apt install localepurge
# sudo apt install git curl
# git clone https://github.com/fguada/debian-post-install
# cd ./debian-post-install
# chmod +x ./debian-post-install.sh
# sh ./debian-post-install.sh

bold=$(tput bold)
reset=$(tput sgr0)

echo '##########################################'
echo "${bold}# SCRIPT DE POST-INSTALLATION DE DEBIAN. #${reset}"
echo '##########################################'

echo
echo "${bold}Configuration interactive de la console.${reset}"
echo

sudo dpkg-reconfigure console-setup

echo
echo "${bold}Création d’une copie de sauvegarde du fichier « /etc/apt/sources.list ».${reset}"
echo

sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

echo
echo "${bold}Ajout des composants « contrib » et « non-free » au même fichier.${reset}"
echo

sudo sed --in-place 's/main non-free-firmware/main non-free-firmware contrib non-free/g' /etc/apt/sources.list

echo
echo "${bold}Configuration des couleurs d’apt.${reset}"
echo

apt_conf_dir='/etc/apt/apt.conf.d'
apt_color_conf='21-colors.conf'
test ! -d "$apt_conf_dir" && sudo mkdir --parents "$apt_conf_dir"
sudo touch "$apt_conf_dir/$apt_color_conf"
sudo echo 'APT::Color::Action::Upgrade "blue";' >|"$apt_conf_dir/$apt_color_conf"

echo
echo "${bold}Mise à jour de la liste des paquets, et installation d’éventuelles mises à jour de ceux-ci.${reset}"
echo

sudo apt-get update -y
sudo apt-get upgrade -y

alias install='sudo apt install -y'

echo
echo "${bold}Installation des paquets.${reset}"
echo

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
diskus \
dmidecode \
docx2txt \
dra \
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
libreoffice-calc \
libreoffice-grammalecte \
libreoffice-help-fr \
libreoffice-java-common \
libreoffice-l10n-fr \
libreoffice-qt6 \
libreoffice-writer \
libxml-dumper-perl \
localepurge \
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
wget \
wl-clipboard \
wlopm \
wlr-randr \
wlrctl \
wmctrl \
xz-utils \
yt-dlp \
zathura"
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

echo
echo "${bold}Configuration de libdvd.${reset}"
echo

sudo dpkg-reconfigure libdvd-pkg

echo
echo "${bold}Création de répertoires nécessaires.${reset}"
echo

userdirs="\
$HOME/Projets
$HOME/bin
$HOME/.local/bin"

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

echo
echo "${bold}INSTALLATION DE LOGICIELS HORS APT.${reset}"
echo

echo
echo "${bold}Installation de dra.${reset}"
echo

curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/devmatteini/dra/refs/heads/main/install.sh | bash -s
chmod +x ./dra
sudo mv --force ./dra /usr/local/bin/

if [ "$SHELL" = 'bash' ]; then
  dra completion bash >|./dra
  sudo mv --force ./dra /usr/local/share/bash-completion/completions
fi

echo
echo "${bold}Installation de bashmount.${reset}"
echo

curl --remote-name https://raw.githubusercontent.com/jamielinux/bashmount/master/bashmount
chmod +x ./bashmount
sudo mv --force ./bashmount /usr/local/bin/

curl --remote-name https://raw.githubusercontent.com/jamielinux/bashmount/refs/heads/master/bashmount.1
sudo mv --force ./bashmount.1 /usr/local/share/man/man1/

echo
echo "${bold}Installation de pastel.${reset}"
echo

dra download --select "pastel_{tag}_amd64.deb" sharkdp/pastel
install ./pastel*.deb
rm ./pastel*.deb

echo
echo "${bold}Installation de uni.${reset}"
echo

dra download --select "uni-v{tag}-linux-amd64.gz" arp242/uni
atool --extract uni*.gz
rm --force uni*.gz
sudo mv --force uni-v*-linux-amd64 /usr/local/bin/uni
sudo chmod +x /usr/local/bin/uni

echo
echo "${bold}Installation de ouch.${reset}"
echo

dra download --select "ouch-x86_64-unknown-linux-gnu.tar.gz" ouch-org/ouch
atool --extract ouch-x86_64-unknown-linux-gnu.tar.gz
sudo mv --force ./ouch-x86_64-unknown-linux-gnu/ouch /usr/local/bin/
sudo chmod +x /usr/local/bin/ouch
sudo mv --force ./ouch-x86_64-unknown-linux-gnu/completions/ouch.bash /usr/local/share/bash-completion/completions/
sudo mv --force ./ouch-x86_64-unknown-linux-gnu/man/* /usr/local/share/man/man1/

echo
echo "${bold}Installation de moar.${reset}"
echo

dra download --select "moar-v{tag}-linux-amd64" walles/moar
sudo mv --force moar-*-*-* /usr/local/bin/moar
sudo chmod +x /usr/local/bin/moar
curl --remote-name https://raw.githubusercontent.com/walles/moar/refs/heads/master/moar.1
sudo mv --force ./moar.1 /usr/local/share/man/man1/

echo
echo "${bold}Installation de fend.${reset}"
echo

dra download --select "fend-{tag}-linux-x86_64-gnu.zip" printfn/fend
atool --extract fend-*-linux-x86_64-gnu.zip
sudo mv --force fend /usr/local/bin/
sudo chmod +x /usr/local/bin/fend
dra download --select "fend.1" printfn/fend
sudo mv --force ./fend.1 /usr/local/share/man/man1/

echo
echo "${bold}Installation de diskus.${reset}"
echo

dra download --select "diskus_{tag}_amd64.deb" sharkdp/diskus
install ./diskus*.deb
sudo rm ./diskus*.deb

# Installation de flacon… Mais les AppImages semblent mal fonctionner sous wayland.
# dra download --select "flacon-{tag}-x86_64.AppImage" flacon/flacon
# sudo mv flacon-*-*.AppImage /usr/local/bin/
# sudo chmod +x /usr/local/bin/flacon-*-*.AppImage

echo
echo "${bold}Installation de advcpmv.${reset}"
echo

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

echo
echo "${bold}Installation de massren.${reset}"
echo

if ! command -v go >/dev/null; then
  install golang
fi

go install github.com/laurent22/massren@latest
sudo cp --force "$GOPATH/bin/massren" /usr/local/bin/massren

echo
echo "${bold}Installation de wl-gammarelay-rs.${reset}"
echo

if ! command -v cargo >/dev/null; then
  echo "Installation de cargo"
  install cargo
fi

echo "Installation de wl-gammarelay-rs"
cargo install wl-gammarelay-rs --locked
sudo cp --force "$CARGO_HOME/bin/wl-gammarelay-rs" /usr/local/bin

echo
echo "${bold}Installation de wlinhibit.${reset}"
echo

dra download --select "x86_64-unknown-linux-gnu" 0x5a4/wlinhibit
sudo mv --force ./"x86_64-unknown-linux-gnu" /usr/local/bin/wlinhibit
sudo chmod +x /usr/local/bin/wlinhibit

echo
echo "${bold}Installation de VSCodium.${reset}"
echo

wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
  | gpg --dearmor \
  | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

echo 'deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg] https://download.vscodium.com/debs vscodium main' \
  | sudo tee /etc/apt/sources.list.d/vscodium.list

sudo apt update && sudo apt install codium

echo
echo "${bold}Installation de batsignal.${reset}"
echo

cd "$HOME/Projets" || exit 1

if [ -d "./batsignal" ]; then
  cd ./batsignal || exit 1
  git pull
else
  git clone https://github.com/electrickite/batsignal
  cd ./batsignal || exit 1
fi

make && sudo make install

echo
echo "${bold}Installation de timemachine.${reset}"
echo

curl --remote-name https://raw.githubusercontent.com/cytopia/linux-timemachine/refs/heads/master/timemachine
chmod +x ./timemachine
sudo mv --force ./timemachine /usr/local/bin/

echo
echo "${bold}Installation de datedirclean.sh.${reset}"
echo

curl --remote-name https://raw.githubusercontent.com/meersjo/toolkit/refs/heads/master/various/datedirclean.sh
chmod +x ./datedirclean.sh
sudo mv --force ./datedirclean.sh /usr/local/bin/

echo
echo "${bold}Correction des permissions des répertoires du système.${reset}"
echo

sudo chmod 755 /usr/local/bin/*
sudo chown root:root /usr/local/bin/*

echo
echo "${bold}Configuration de « /etc/systemd/logind.conf ».${reset}"
echo

sudo sed --in-place 's/^#HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
sudo sed --in-place 's/^#IdleAction=.*/IdleAction=suspend/' /etc/systemd/logind.conf
sudo sed --in-place 's/^#IdleActionSec=.*/IdleActionSec=4min/' /etc/systemd/logind.conf

echo
echo "${bold}Configuration de grub.${reset}"
echo

sudo sed --in-place 's/GRUB_TIMEOUT=./GRUB_TIMEOUT=2/' "/etc/default/grub"
sudo update-grub

echo
echo "${bold}Établissement de liens symboliques de batcat et fdfind vers bat et fd.${reset}"
echo

sudo ln -s /usr/bin/batcat /usr/local/bin/bat
sudo ln -s /usr/bin/fdfind /usr/local/bin/fd

echo
echo "${bold}Création du mot de passe du compte root.${reset}"
echo

sudo passwd root

echo '######################################'
echo "${bold}# CONFIGURATION DES DONNÉES PRIVÉES. #${reset}"
echo '######################################'

sudo ln -s "/home/franck/.config/xkb/symbols/custom" "/usr/share/X11/xkb/rules/"

ln -s "/home/franck/.config/lf/marks" "/home/franck/.local/share/lf/"

# Rendre exécutable le script de nettoyage des images affichées par lf dans kitty.
chmod +x "/home/franck/.config/lf/lf_kitty_clean"

## Configurer le clavier (y compris celui de la console?).
sudo dpkg-reconfigure keyboard-configuration

# Ou ceci?
sudo echo -e '# KEYBOARD CONFIGURATION FILE
# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="custom"
XKBOPTIONS="compose:ins,nbsp:level3n,kpdl:comma"
BACKSPACE="guess"
XKBVARIANT="fg_invert_home_end_with_pageup_pagedown,"' >|/etc/default/keyboard

update-alternatives --config editor
sudo update-alternatives --config editor

# À COMPILER
# hyprpicker

## désactiver certains services inutiles (il peut aussi être nécessaires de les masquer, pour empêcher que d'autres processus ne les lancent)
# systemctl --user disable gvfs-goa-volume-monitor.service
# systemctl --user mask gvfs-goa-volume-monitor.service
# sudo systemctl disable ModemManager.service
# sudo systemctl disable cups.service
# sudo systemctl disable cups-browsed.service
# sudo systemctl disable accounts-daemon
# sudo systemctl mask accounts-daemon
