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
# add ani-cli to sources list for installation via package manager
wget -qO- https://Wiener234.github.io/ani-cli-ppa/KEY.gpg | tee /etc/apt/trusted.gpg.d/ani-cli.asc
wget -qO- https://Wiener234.github.io/ani-cli-ppa/ani-cli-debian.list | tee /etc/apt/sources.list.d/ani-cli-debian.list
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

# install building stuff
apt install build-essential libtool pkg-config unzip -y

# install dependencies for st and dwm
apt install libx11-dev libxext-dev libxft-dev libxrender-dev libfontconfig1-dev libfreetype6-dev \
	libx11-xcb-dev libxcb-res0-dev libxinerama-dev xutils-dev -y

# install x 
apt install xinit xwallpaper -y

# install browser
apt install firefox -y

#install youtube downloader
apt install yt-dlp -y

# install video player
apt install mpv -y

# install image viewer
apt install sxiv -y

# install music player
apt install mpd ncmpcpp -y

# install ani-cli
apt install ani-cli -y

# install fonts
wget "https://github.com/ryanoasis/nerd-font/releases/download/v2.2.2/Hack.zip"
mkdir -p /usr/share/fonts/hackfont
unzip "Hack.zip" -d /usr/share/fonts/hackfont/
fc-cache -vf
rm Hack.zip

# install dwm
cd /home/$username/.local/src
git clone https://github.com/yuzu-eva/my-personal-dwm.git dwm
cd dwm
make && make install

# install st
cd /home/$username/.local/src
git clone https://github.com/yuzu-eva/my-personal-st.git st
cd st
make && make install

#install dmenu
cd /home/$username/.local/src
git clone https://github.com/yuzu-eva/my-personal-dmenu.git dmenu
cd dmenu
make && make install


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

chown -R $username:$username /home/$username
chown root:root /home

echo "First of all: reboot!
Install ssh-keys for github and openSSH
git set upstream for dfiles, dwm, st and dmenu
dfiles update-index --assume-unchanged for files you don't need before deleting them
Customize .xinitrc (also assume unchanged!)
Customize .bashrc and .bash_profile
Customize .config/user-dirs.dirs file
Configure /etc/fstab for HDD and USB-Sticks
Copy scripts from USB into ~/.local/bin/
Install and configure postfix, mailutils and mutt
Install and configure openSSH and sshd
Configure sudoers
Configure ufw" >/home/$username/TODO

