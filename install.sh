#!/bin/sh

# install script for debian unstable

# check if script is run as root
if [ $EUID -ne 0 ]; then
	echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
	exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

# change debian so unstable branch
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cp sources.list /etc/apt/sources.list

# update packages list and update system
apt update
apt upgrade -y

mkdir -p /home/$username/.config
mkdir -p /home/$username/.local/src
mkdir -p /home/$username/.local/bin
mkdir -p /home/$username/dl/torrents
mkdir -p /home/$username/pics
mkdir -p /home/$username/vids
mkdir -p /home/$username/docs
mkdir -p /home/$username/games

## installing important  stuff
# install building stuff
apt install build-essential libtool pkg-config unzip -y

# install dependencies for st and dwm
apt install libx11-dev libxext-dev libxft-dev libxrender-dev libfontconfig1-dev libfreetype6-dev \
	libx11-xcb-dev libxcb-res0-dev libxinerama-dev xutils-dev -y

apt install xinit -y

# install dwm
cd /home/$username/.local/src
git clone https://github.com/yuzu-eva/my-personal-dwm dwm
cd dwm
make && make install

# install st
cd /home/$username/.local/src
git clone https://github.com/yuzu-eva/my-personal-st st
cd st
make && make install

#install dmenu
cd /home/$username/.local/src
git clone https://github.com/yuzu-eva/my-personal-dmenu dmenu
cd dmenu
make && make install

cd $builddir

# install browser
apt install firefox -y

## installing less important stuff
# install video player
apt install mpv -y

# install image viewer
apt install sxiv -y

# install music player
apt install mpd ncmpcpp -y

# install fonts
wget "https://github.com/ryanoasis/nerd-font/releases/download/v2.2.2/Hack.zip"
mkdir -p /usr/share/fonts/hackfont
unzip "Hack.zip" -d /usr/share/fonts/hackfont/
fc-cache -vf
rm Hack.zip

# clone my dotfiles repository
cd /home/$username

git clone --bare https://github.com/yuzu-eva/dotfiles.git .dotfiles

function dfiles {
	/usr/bin/git --git-dir=/home/$username/.dotfiles/ --work-tree=/home/$username $@
}

mkdir .config-backup

dfiles checkout
if [ $? = 0 ]; then
	echo "Checked out config.";
else
	echo "Backing up pre-existing dotfiles.";
	dfiles checkout 2>&1 | egrep "\s+\." | awk '{ print $1 }' | xargs -I{} mv {} .config-backup/{}
fi

dfiles checkout
dfiles config status.showUntrackedFiles no

