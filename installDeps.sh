#!/bin/sh

oldwhich(){
	aresult="$(which "$1" 2>&1 2>/dev/null)"
	retval="$?"
	if [ "$retval" = "0" ]; then
		echo "$aresult"
		return 0
	else
		return $retval
	fi
}

if [ "$(uname -m | tr -d '\n')" != "x86_64" ]; then
	echo "This script was designed for x86_64 linux."
	echo "It will probably need modifying to get it to run on anything else."
	echo "Exiting."
	exit
fi

OLD_UMASK="$(umask)"
umask 0022

#echo "You must have contrib added to /etc/apt/sources.list before you continue."
#echo "Check now and type y if you are sure."

#read isyes

#if [ "$isyes" != "y" ] && [ "$isyes" != "y" ]; then
#exit
#fi

if [ "$(oldwhich apt-get)" != "" ]; then
	#we have to build cdemu for debian as there isn't a package availiable.

	sudo apt-get update
	sudo apt-get upgrade

	sudo dpkg --add-architecture i386
	sudo apt-get update

	sudo apt-get install -y wine wine32:i386 zenity git dosbox wget winetricks python3-pip xorg-server-xnest

	git clone git://git.code.sf.net/p/cdemu/code cdemu-code

	sudo apt-get install -y linux-image-amd64 linux-headers-amd64 build-essential dpkg-dev pkg-config libglib2.0-dev libsndfile1-dev libsamplerate0-dev zlib1g-dev libbz2-dev liblzma-dev gtk-doc-tools gobject-introspection libgirepository1.0-dev gir1.2-glib-2.0-dev debhelper intltool cmake libglib2.0-dev libao-dev debhelper intltool cmake dkms dh-dkms dh-python bash-completion libgcrypt20-dev

	if [ "$(oldwhich "dbus-user-session")" = "" ]; then
		sudo apt-get install -y dbus-x11
	fi

	cd cdemu-code

	cd libmirage

	dpkg-buildpackage -b -uc -tc

	cd ..

	sudo dpkg -i ./*.deb

	mkdir out

	mv ./*.deb out/

	cd vhba-module

	dpkg-buildpackage -b -uc -tc

	cd ..

	sudo dpkg -i ./*.deb

	mv ./*.deb out/

	cd cdemu-daemon

	if [ "$(oldwhich "dbus-user-session")" = "" ]; then
		sed -i "s#dbus-user-session#dbus-x11#g" debian/control
	fi

	dpkg-buildpackage -b -uc -tc

	cd ..

	sudo dpkg -i ./*.deb

	mv ./*.deb out/

	cd cdemu-client

	dpkg-buildpackage -b -uc -tc

	cd ..

	sudo dpkg -i ./*.deb

	mv ./*.deb out/

	cd ..

elif [ "$(oldwhich pacman)" != "" ]; then
	sudo pacman -Syu

	#if [ "$(pacman -Q | grep firejail-git 2>/dev/null)" = "" ]; then
	#	echo "You need to install firejail-git from AUR to continue"
	#	exit
	#fi 

	sudo pacman -S wine zenity git dosbox wget winetricks cdemu-client python-pip

	git clone https://aur.archlinux.org/liblnk-git.git
	cd liblnk-git
	gpg --recv-keys D9625E5D7AD0177E
	makepkg -si
	cd ..

	git clone https://aur.archlinux.org/nx.git
	cd nx
	makepkg -si
	cd ..

else
	echo "Package manager not found, exiting."
	exit
fi

	systemctl status systemd-logind.service 2>/dev/null 1>/dev/null
	if [ "$?" = 0 ]; then
		#using systemd
		#make udev rule so vhba can load ok
		echo 'KERNEL=="vhba_ctl", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=vhba_ctl"' | sudo tee /lib/udev/rules.d/69-vhba.rules
		sudo chmod 0644 /lib/udev/rules.d/69-vhba.rules
	else
		#using elogind
		#make udev rule so vhba can load ok
		echo 'KERNEL=="vhba_ctl", SUBSYSTEM=="misc", MODE="0660", GROUP="cdrom"' | sudo tee /lib/udev/rules.d/69-vhba.rules
		sudo chmod 0644 /lib/udev/rules.d/69-vhba.rules

		if [ "$(grep cdrom /etc/group)" = "" ]; then
			sudo groupadd cdrom
		fi

		echo "Would you like to add current user to cdrom group?"
		read yesorno
		if [ "${yesorno}" = "y" ] || [ "${yesorno}" = "Y" ] || [ "${yesorno}" = "yes" ] || [ "${yesorno}" = "Yes" ] || [ "${yesorno}" = "YES" ]; then
			sudo usermod -aG cdrom $(whoami)
		fi
	fi

mkdir "${HOME}/sandwine"
cd "${HOME}/sandwine"
python3 -m venv .venv
. .venv/bin/activate
pip install --upgrade pip
pip3 install sandwine

#do this else python cant run "gi" module
if [ "$(oldwhich pacman)" != "" ]; then
pip install PyGObject
fi



	echo
	echo
	echo "DONE"
	echo "*** YOU WILL NEED TO RESTART YOUR SYSTEM TO RUN WINE TIPPLE LOADER! ***"
	echo

umask "${OLD_UMASK}"
