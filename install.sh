#!/bin/sh

# install script for debian unstable

username=$(id -u -n 1000)
builddir=$(pwd)

# change debian to unstable branch
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cp sources.list /etc/apt/sources.list

# update packages list and update system
# add ani-cli to sources list for installation via package manager
wget -qO- https://Wiener234.github.io/ani-cli-ppa/KEY.gpg | tee /etc/apt/trusted.gpg.d/ani-cli.asc
wget -qO- https://Wiener234.github.io/ani-cli-ppa/ani-cli-debian.list | tee /etc/apt/sources.list.d/ani-cli-debian.list
apt update
apt upgrade -y

mkdir -p /home/$username/.local/src
mkdir -p /home/$username/.local/bin
mkdir -p /home/$username/dl/torrents
mkdir -p /home/$username/pics
mkdir -p /home/$username/vids
mkdir -p /home/$username/docs
mkdir -p /mnt/usb
mkdir -p /media/hdd

# various packages
apt install build-essential libtool pkg-config unzip zstd lshw zathura zsh \
	sysstat mutt newsboat tmux ntfs-3g-dev firmware-linux firmware-amd-graphics -y

# dependencies for st and dwm
apt install libx11-dev libxext-dev libxft-dev libxrender-dev libfontconfig1-dev libfreetype6-dev \
	libx11-xcb-dev libxcb-res0-dev libxinerama-dev xutils-dev -y

# various Xorg stuff
apt install xinit xwallpaper picom xdotool xclip libxrandr-dev scrot -y

# browser of choice (need to specify sysvinit here, otherwise apt tries to uninstall it)
# this step requires confirmation to make sure systemd will not be installed!
apt install firefox sysvinit-core libgtk-3-0

# youtube downloader
apt install yt-dlp -y

# video player
apt install mpv -y

# simple image viewer
apt install sxiv -y

# music player daemon and some libs for manually compiling ncmpcpp
# still need to install taglib manually
apt install mpd libfftw3-dev libboost1.74-all-dev libcurl4-gnutls-dev \
	libreadline-dev libmpdclient-dev cmake y

# watch anime from CLI via yt-dlp and mpv
apt install ani-cli -y

# fd-find for fzf
apt install fd-find -y

# hack nerd font for terminal, dwm and dmenu
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip
mkdir -p /usr/share/fonts/hackfont
unzip Hack.zip -d /usr/share/fonts/hackfont/

# joypixels
wget -qO joypixels.pkg.tar.zst https://archlinux.org/packages/community/any/ttf-joypixels/download
tar -I zstd -xvf joypixels.pkg.tar.zst
mv usr/share/fonts/joypixels /usr/share/fonts/
mv usr/share/licences/ttf-joypixels /usr/share/licences/

fc-cache -vf

# my own build of dwm
cd /home/$username/.local/src
git clone https://github.com/yuzu-eva/my-personal-dwm.git dwm
cd dwm
make && make install

# my own build of st
cd /home/$username/.local/src
git clone https://github.com/yuzu-eva/my-personal-st.git st
cd st
make && make install

# my own build of dmenu
cd /home/$username/.local/src
git clone https://github.com/yuzu-eva/my-personal-dmenu.git dmenu
cd dmenu
make && make install

cd /home/$username

dfiles(){
	/usr/bin/git --git-dir=/home/$username/.dotfiles/ --work-tree=/home/$username $@
}

git clone --bare https://github.com/yuzu-eva/dotfiles.git /home/$username/.dotfiles

if [ -f ~/.bashrc ]; then
	rm .bashrc
fi

# desktop or laptop
dfiles checkout
dfiles config --local status.showUntrackedFiles no

cp $builddir/user-dirs.dirs /home/$username/.config/
mkdir -p /home/$username/.config/mpd/playlists
touch /home/$username/.config/mpd/database

chown -R $username:$username /home/$username
chown -R $username:$username /media/hdd
chown -R $username:$username /mnt/usb
chown root:root /mnt
chown root:root /home

# make zsh default shell
chsh -s /usr/bin/zsh $username

echo "DONE"
echo $?
