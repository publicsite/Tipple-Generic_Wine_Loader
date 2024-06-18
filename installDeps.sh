#!/bin/sh

#echo "You must have contrib added to /etc/apt/sources.list before you continue."
#echo "Check now and type y if you are sure."

#read isyes

#if [ "$isyes" != "y" ] && [ "$isyes" != "y" ]; then
#exit
#fi

sudo dpkg --add-architecture i386
sudo apt-get update

sudo apt-get install -y wine wine32:i386 firejail zenity git dosbox wget #winetricks

git clone git://git.code.sf.net/p/cdemu/code cdemu-code

sudo apt-get install -y linux-headers-amd64 build-essential dpkg-dev pkg-config libglib2.0-dev libsndfile1-dev libsamplerate0-dev zlib1g-dev libbz2-dev liblzma-dev gtk-doc-tools gobject-introspection libgirepository1.0-dev gir1.2-glib-2.0-dev debhelper intltool cmake libglib2.0-dev libao-dev debhelper intltool cmake dkms dh-dkms dh-python bash-completion

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