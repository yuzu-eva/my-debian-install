#!/bin/sh

# install script for debian unstable

# check if script is run as root
if [ $EUID -ne 0 ]; then
	echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
	exit 1
fi

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
mkdir -p /home/$username/games
mkdir -p /mnt/usb
mkdir -p /hdd

# package building stuff
apt install build-essential libtool pkg-config unzip zstd -y

# dependencies for st and dwm
apt install libx11-dev libxext-dev libxft-dev libxrender-dev libfontconfig1-dev libfreetype6-dev \
	libx11-xcb-dev libxcb-res0-dev libxinerama-dev xutils-dev -y

# for startx and wallpaper
apt install xinit xwallpaper picom -y

# the most essential package of all. No system can run without it.
apt install neofetch

# terminal multiplexer
apt install tmux

# browser of choice
apt install firefox -y

# youtube downloader
apt install yt-dlp -y

# video player
apt install mpv -y

# simple image viewer
apt install sxiv -y

# ncurses music player
apt install mpd ncmpcpp -y

# watch anime from CLI
apt install ani-cli -y

# hack nerd font for terminal, dwm and dmenu
wget -qO Hack.zip https://github.com/ryanoasis/nerd-font/releases/download/v2.2.2/Hack.zip
mkdir -p /usr/share/fonts/hackfont
unzip Hack.zip -d /usr/share/fonts/hackfont/

# joypixels (just tesing if it even works, lol)
wget -qO joypixels.pkg.tar.zst https://archlinux.org/packages/community/any/ttf-joypixels/download
tar -I zstd -xvf joypixels.pkg.tar.zst
mv usr/share/fonts/joypixels /usr/share/fonts/
mv usr/share/licences/ttf-joypixels /usr/share/licences/

fc-cache -vf
rm -rf Hack.zip joypixels.pkg.tar.zst usr/

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

# starship custom shell prompt
curl -sS https://starship.rs/install.sh | sh

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
dfiles config --local status.showUntrackedFiles no

echo "Install ssh-keys for github and openSSH
Configure global git settings
git set upstream for dfiles, dwm, st and dmenu
dfiles update-index --assume-unchanged for files you don't need before deleting them
Customize .xinitrc (also assume unchanged!)
Rename compton in .config to picom, also change in .xinitrc
Customize .bashrc and .bash_profile
Customize .config/user-dirs.dirs file
Configure /etc/fstab for HDD and USB-Sticks
Copy scripts from USB into ~/.local/bin/
Install and configure postfix, mailutils, mutt and fetchmail
Install and configure openSSH and sshd
Install and configure dunst
Configure sudoers
Configure ufw
Install and configure firefox extensions and user scripts
Install password manager and copy database
Copy documents from USB to ~/docs
Install emacs and add personal configuration
Install ttf-symbola if joypixels don't work" >/home/$username/TODO

chown -R $username:$username /home/$username
chown -R $username:$username /hdd
chown -R $username:$username /mnt/usb
chown root:root /mnt
chown root:root /home
