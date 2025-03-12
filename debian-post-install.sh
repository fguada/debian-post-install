#!/bin/sh

# À faire *avant* l'exécution de ce script:
# sudo apt install localepurge
# sudo apt install git curl
# git clone fguada…

# Debian Linux Post-Installation Script for Wayland

# Enable debugging output and exit on error
# set -x

# Add user to sudo group
# sudo usermod -aG sudo "$USER"

# Backup the existing sources.list file
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Add contrib and non-free to the sources.list
sudo sed --in-place '/^deb .* main/{s/main/main contrib non-free/;t;}' /etc/apt/sources.list
sudo sed --in-place 's/^#deb/deb/g}' /etc/apt/sources.list

# On change légèrement les couleurs de apt.
sudo touch "/etc/apt/apt.conf.d/21-colors.conf"
sudo echo 'APT::Color::Action::Upgrade "blue";' >|"/etc/apt/apt.conf.d/21-colors.conf"

# Update package lists and upgrade existing packages
sudo apt-get update -y
sudo apt-get upgrade -y

alias install='sudo apt install -y'

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

install curl eject udisks2

curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/devmatteini/dra/refs/heads/main/install.sh | bash -s -- --to ~/bin/
chmod +x ~/bin/dra

curl --remote-name https://raw.githubusercontent.com/jamielinux/bashmount/master/bashmount
chmod +x ./bashmount
sudo mv --force ./bashmount /usr/local/bin/

curl --remote-name https://raw.githubusercontent.com/jamielinux/bashmount/refs/heads/master/bashmount.1
sudo mv --force ./bashmount.1 /usr/local/share/man/man1/

pkgs="\
alacritty
arc
arj
atool
bash-completion
bat
bc
bfs
blueman
bluez
bluez-tools
brightnessctl
bsdutils
bzip2
calibre
cargo
catdoc
chafa
chromium
chromium-l10n
clinfo
cliphist
cmake
colordiff
colortest-python
cpio
curl
dbus
dconf-editor
dex
dictionaries-common
diffutils
diskus
dmidecode
docx2txt
dra
du-dust
duf
dust
e2fsprogs
exfatprogs
exif
eza
fastfetch
fd-find
fdisk
ffmpegthumbnailer
firefox-esr
firefox-esr-l10n-fr
foot
fzf
galternatives
gcal
glxinfo
gnome-characters
gnome-epub-thumbnailer
golang
gparted
grim
gucharmap
gvfs
gvfs-backends
gvfs-fuse
gzip
htop
hunspell
hyperfine
hyphen-fr
imagemagick
info
inxi
iso-info
jekyll
jq
kanshi
keepassxc
kid3-qt
kitty
kitty-terminfo
labwc
lf
libcpanel-json-xs-perl
libdvd-pkg
libfuse2t64
libglib2.0-bin
libnotify-bin
libnotify-dev
libreoffice-calc
libreoffice-grammalecte
libreoffice-help-fr
libreoffice-java
libreoffice-l10n-fr
libreoffice-qt6
libreoffice-writer
libxml-dumper-perl
localepurge
lxpolkit
lzip
lzop
mako-notifier
mediainfo
meson
micro
mintstick
moreutils
mousepad
mpv
neovim
network-manager
nomarch
odt2txt
pandoc
parallel
pdfarranger
plocate
poppler-utils
qbittorrent
qimgv
qt5ct
qt6ct
rar
rclone
regionset
rfkill
ripgrep
rpm
rsync
ruby-jekyll-paginate
ruby-jekyll-sitemap
screenruler
sd
sensible-utils
shellcheck
shfmt
slurp
swayidle
tar
tealdeer
thunar
thunar-archive-plugin
thunar-gtkhash
thunar-media-tags-plugin
thunar-volman
thunderbird
thunderbird-l10n-fr
timeshift
transmission-cli
trash-cli
tree
unace
unalz
unrar
upower
vainfo
vlc
vlc-plugin-pipewire
vulkan-tools
wayland-utils
wev
wget
wl-clipboard
wlopm
wlr-randr
wlrctl
wmctrl
xz-utils
yt-dlp
zathura"
# abcde
# archivemount
# atril
# catfish
# featherpad
# network-manager-gnome
# numlockx
# parted
# partitionmanager
# pavucontrol-qt
# pavucontrol-qt-l10n
# qpdf
# quodlibet
# sxhkd
# synaptic
# syncthing
# transmission-qt
# xarchiver
# xcalib
# xcape
# xclip
# xdotool
# xfce4
# xfce4-appfinder
# xfce4-notifyd
# xfce4-panel
# xfce4-power-manager
# xfce4-pulseaudio-plugin
# xfce4-screenshooter
# xfce4-session
# xfce4-settings
# xfce4-terminal
# xfce4-xkb-plugin
# xfconf
# xfwm4

install "$pkgs"

# Enable and start timesync service
# sudo systemctl enable --now systemd-timesyncd

# Enable and start bluetooth service
# sudo systemctl enable --now bluetooth

# Enable and start polkitd
# sudo systemctl enable --now polkitd

# Enable and start rtkit
# sudo systemctl enable --now rtkit

# Set up NetworkManager
# sudo systemctl stop wpa_supplicant
# sudo systemctl disable --now wpa_supplicant

# sudo systemctl disable --now systemd-networkd
# sudo systemctl mask systemd-networkd

# sudo systemctl enable --now dbus
# sudo systemctl enable --now NetworkManager

# Clone and set up dotfiles
# git clone https://github.com/speyll/dotfiles "$HOME/dotfiles"
# cp -r "$HOME/dotfiles/."* "$HOME/"
# rm -rf "$HOME/dotfiles"
# chmod -R +X "$HOME/.local/bin" "$HOME/.local/share/applications" "$HOME/.config/autostart/"
# chmod +x "$HOME/.config/yambar/sway-switch-keyboard.sh" "$HOME/.config/yambar/xkb-layout.sh" "$HOME/.config/autostart/*" "$HOME/.local/bin/*"
# ln -s "$HOME/.config/mimeapps.list" "$HOME/.local/share/applications/"

# Add user to sudo group for sudo access
# echo "%sudo ALL=(ALL:ALL) NOPASSWD: /usr/bin/halt, /usr/bin/poweroff, /usr/bin/reboot, /usr/bin/shutdown, /usr/bin/zzz, /usr/bin/ZZZ" | sudo tee -a /etc/sudoers.d/wheel

# Créaction du mot de passe du compte root.
sudo passwd root

# Configuration de la console.
sudo dpkg-reconfigure console-setup

sudo sed --in-place 's/GRUB_TIMEOUT=./GRUB_TIMEOUT=2/' "/etc/default/grub"
sudo update-grub

sudo ln -s "/home/franck/.config/xkb/symbols/custom" "/usr/share/X11/xkb/rules/"

ln -s "/home/franck/.config/lf/marks" "/home/franck/.local/share/lf/"

sudo ln -s /usr/bin/batcat /usr/local/bin/bat
sudo ln -s /usr/bin/fdfind /usr/local/bin/fd

# Rendre exécutable le script de nettoyage des images affichées par lf dans kitty.
chmod +x "/home/franck/.config/lf/lf_kitty_clean"

# Après avoir installé
sudo dpkg-reconfigure libdvd-pkg

if [ "$SHELL" = 'bash' ]; then
  dra completion bash >|./dra
  sudo mv --force ./dra /usr/local/share/bash-completion/completions
fi

dra download --select "pastel_{tag}_amd64.deb" sharkdp/pastel
install ./pastel*.deb
rm ./pastel*.deb

dra download --select "uni-v{tag}-linux-amd64.gz" arp242/uni
atool --extract uni*.gz
rm --force uni*.gz
sudo mv --force uni-v*-linux-amd64 /usr/local/bin/uni
sudo chmod +x /usr/local/bin/uni

dra download --select "ouch-x86_64-unknown-linux-gnu.tar.gz" ouch-org/ouch
atool --extract ouch-x86_64-unknown-linux-gnu.tar.gz
sudo mv --force ./ouch-x86_64-unknown-linux-gnu/ouch /usr/local/bin/
sudo chmod +x /usr/local/bin/ouch
sudo mv --force ./ouch-x86_64-unknown-linux-gnu/completions/ouch.bash /usr/local/share/bash-completion/completions/
sudo mv --force ./ouch-x86_64-unknown-linux-gnu/man/* /usr/local/share/man/man1/

dra download --select "moar-v{tag}-linux-amd64" walles/moar
sudo mv --force moar-*-*-* /usr/local/bin/moar
sudo chmod +x /usr/local/bin/moar
curl --remote-name https://raw.githubusercontent.com/walles/moar/refs/heads/master/moar.1
sudo mv --force ./moar.1 /usr/local/share/man/man1/

dra download --select "fend-{tag}-linux-x86_64-gnu.zip" printfn/fend
atool --extract fend-*-linux-x86_64-gnu.zip
sudo mv --force fend /usr/local/bin/
sudo chmod +x /usr/local/bin/fend
dra download --select "fend.1" printfn/fend
sudo mv --force ./fend.1 /usr/local/share/man/man1/

dra download --select "diskus_{tag}_amd64.deb" sharkdp/diskus
install ./diskus*.deb
sudo rm ./diskus*.deb

# Installation de flacon… Mais les AppImages semblent mal fonctionner sous wayland.
# dra download --select "flacon-{tag}-x86_64.AppImage" flacon/flacon
# sudo mv flacon-*-*.AppImage /usr/local/bin/
# sudo chmod +x /usr/local/bin/flacon-*-*.AppImage

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

echo "Installation de massren."

if ! command -v go >/dev/null; then
  install golang
fi

go install github.com/laurent22/massren@latest
sudo cp --force "$GOPATH/bin/massren" /usr/local/bin/massren

if ! command -v cargo >/dev/null; then
  echo "Installation de cargo"
  install cargo
fi

echo "Installation de wl-gammarelay-rs"
cargo install wl-gammarelay-rs --locked
sudo cp --force "$CARGO_HOME/bin/wl-gammarelay-rs" /usr/local/bin

dra download --select "x86_64-unknown-linux-gnu" 0x5a4/wlinhibit
sudo mv --force ./"x86_64-unknown-linux-gnu" /usr/local/bin/wlinhibit
sudo chmod +x /usr/local/bin/wlinhibit

wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
  | gpg --dearmor \
  | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

echo 'deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg] https://download.vscodium.com/debs vscodium main' \
  | sudo tee /etc/apt/sources.list.d/vscodium.list

sudo apt update && sudo apt install codium

cd "$HOME/Projets" || exit 1

if [ -d "./batsignal" ]; then
  cd ./batsignal || exit 1
  git pull
else
  git clone https://github.com/electrickite/batsignal
  cd ./batsignal || exit 1
fi

make && sudo make install

# Correction des permissions des répertoires du système.
sudo chmod 755 /usr/local/bin/*
sudo chown root:root /usr/local/bin/*
# à compiler
# hyprpicker

update-alternatives --config editor
sudo update-alternatives --config editor

sudo sed --in-place 's/^#HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
sudo sed --in-place 's/^#IdleAction=.*/IdleAction=suspend/' /etc/systemd/logind.conf
sudo sed --in-place 's/^#IdleActionSec=.*/IdleActionSec=4min/' /etc/systemd/logind.conf

## désactiver certains services inutiles (il peut aussi être nécessaires de les masquer, pour empêcher que d'autres processus ne les lancent)
systemctl --user disable gvfs-goa-volume-monitor.service
systemctl --user mask gvfs-goa-volume-monitor.service
sudo systemctl disable ModemManager.service
sudo systemctl disable cups.service
sudo systemctl disable cups-browsed.service
sudo systemctl disable accounts-daemon
sudo systemctl mask accounts-daemon

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

curl --remote-name https://raw.githubusercontent.com/cytopia/linux-timemachine/refs/heads/master/timemachine
chmod +x ./timemachine
sudo mv --force ./timemachine /usr/local/bin/

curl --remote-name https://raw.githubusercontent.com/meersjo/toolkit/refs/heads/master/various/datedirclean.sh
chmod +x ./datedirclean.sh
sudo mv --force ./datedirclean.sh /usr/local/bin/
