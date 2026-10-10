#!/bin/busybox sh

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

OLD_UMASK="$(umask)"
umask 0022

usesandwine="true"
usenetworking="true"

sandnetworkoption=""
if [ "$usenetworking" = "true" ]; then
	sandnetworkoption="--network"
fi

if [ "$(oldwhich zenity)" = "" ]; then
	echo "You need to install zenity to proceed."
	exit
fi

if [ "$(oldwhich wine)" = "" ]; then
	echo "You need to install wine to proceed."
	exit
fi

if [ "$(oldwhich winecfg)" = "" ]; then
	echo "You need to install winecfg to proceed."
	exit
fi

if [ "$(oldwhich winetricks)" = "" ]; then
	echo "You need to install winetricks to proceed."
	exit
fi

cd "$(dirname ${0})/fakehome"

thepwd="${PWD}"

if [ ! -d "$HOME/sandwine" ] && [ "$usesandwine" = "true" ]; then
	echo "You need to install sandwine and PyGObject with pip to continue."
	exit
fi

if [ -d "$HOME/sandwine" ]; then
	cd "$HOME/sandwine"
	. .venv/bin/activate
	cd "$thepwd"
fi


firstpath="$(find "$PWD/EXE/1" -maxdepth 1 -type f -name "*.exe" | head -n 1)"
if [ "$firstpath" = "" ]; then
	firstpath="$(find "$PWD/EXE/1" -maxdepth 1 -type f -name "*.EXE" | head -n 1)"
fi

starterProg="$firstpath"

if [ "$(file "$starterProg" | grep "64")" = "" ]; then
	numofbits=32
else
	numofbits=64
fi

echo "${numofbits}" > "${thepwd}/numofbits.txt"

if [ ! -d "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}" ]; then

	mkdir -p "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}"

	zenity --info --title="Please make 'generic' wine config." --text="Set your default version of Windoze."

	#fix accessability bus error when running winetricks
	if [ ! -d "${thepwd}/.cache/at-spi" ] && [ ! -L "${thepwd}/.cache/at-spi" ]; then
		mkdir -p "${thepwd}/.cache"
		cd "${thepwd}/.cache"
		ln -s "${HOME}/.cache/at-spi" at-spi
		cd "${thepwd}"
	fi

	if [ "$usesandwine" = "true" ]; then
		if [ "$(oldwhich wine32)" != "" ]; then
			WINEPREFIX="${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}" HOME="${HOME}/WINEHOMES/WINE_SKELETON/fakehome" WINEARCH=win${numofbits} sandwine ${sandnetworkoption} --pulseaudio --x11 --dotwine "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/:rw" --pass "$HOME/.dosbox:ro" --pass "$HOME/.cache/wine:rw" --configure
			WINEPREFIX="${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}" NO_AT_BRIDGE=1 GTK_A11Y=none winetricks
		else
			WINEPREFIX="${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}" HOME="${HOME}/WINEHOMES/WINE_SKELETON/fakehome" sandwine ${sandnetworkoption} --pulseaudio --x11 --dotwine "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/:rw" --pass "$HOME/.dosbox:ro" --pass "$HOME/.cache/wine:rw" --configure
			WINEPREFIX="${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}" NO_AT_BRIDGE=1 GTK_A11Y=none winetricks
		fi
	else
		WINEPREFIX="${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}" winecfg
		WINEPREFIX="${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}" winetricks
	fi

#We don't want to use the Z drive!
rm -r "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/AppData/Roaming/Microsoft/Windows/Templates"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/AppData/Roaming/Microsoft/Windows/Templates"
rm -r "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/Pictures"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/Pictures"
rm -r "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/Videos"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/Videos"
rm -r "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/Desktop"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/Desktop"
rm -r "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/Downloads"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/Downloads"
rm -r "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/Music"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/Music"
rm -r "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/Documents"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/drive_c/users/$(whoami)/Documents"
rm -r "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}/dosdevices/z:"

fi

if [ ! -d "${thepwd}/.wine${numofbits}" ]; then
	cp -a "${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}" "${thepwd}/"
fi

#echo "LINKING Z"
cd "${thepwd}/.wine${numofbits}/dosdevices"
ln -s "${thepwd}" "z:" 
cd "${thepwd}"

yesno=0
while true; do
	zenity --question --title "Alert" --text "Would you like to run winecfg and winetricks for this application specifically?"
	if [ "$?" = "0" ]; then

		if [ "$usesandwine" = "true" ]; then
			if [ "$(oldwhich wine32)" != "" ]; then

				WINEPREFIX="${thepwd}/.wine${numofbits}" WINEARCH=win${numofbits} HOME="${thepwd}" sandwine ${sandnetworkoption} --pulseaudio --x11 --dotwine ${thepwd}/.wine${numofbits}/:rw --pass "${thepwd}/.dosbox:ro" --pass "${thepwd}/.cache/wine:rw" --pass "${thepwd}/EXE:ro" --configure --
				WINEPREFIX="${thepwd}/.wine${numofbits}" WINEARCH=win${numofbits} HOME="${thepwd}" NO_AT_BRIDGE=1 GTK_A11Y=none sh -c "winetricks"
			else
				WINEPREFIX="${thepwd}/.wine${numofbits}" HOME="${thepwd}" sandwine ${sandnetworkoption} --pulseaudio --x11 --dotwine ${thepwd}/.wine${numofbits}/:rw --pass "${thepwd}/.dosbox:ro" --pass "${thepwd}/.cache/wine:rw" --pass "${thepwd}/EXE:ro" --configure --
				WINEPREFIX="${thepwd}/.wine${numofbits}" HOME="${thepwd}" NO_AT_BRIDGE=1 GTK_A11Y=none sh -c "winetricks"			fi
			fi
		else
			WINEPREFIX="${thepwd}/.wine${numofbits}" winecfg
			WINEPREFIX="${thepwd}/.wine${numofbits}" winetricks
		fi
	
		break;
	else
		break;
	fi
done







##echo "mkdir -p /tmp/overlay "${PWD}/.wine${numofbits}" "${PWD}/.wine${numofbits}_modifications"
##echo "sudo mount -t overlay overlay -o lowerdir="${HOME}/WINEHOMES/WINE_SKELETON/fakehome/.wine${numofbits}",upperdir="${PWD}/.wine${numofbits}_modifications",workdir="${PWD}/.wine${numofbits}" "${PWD}/.wine${numofbits}"

#tofix:use firejail
#echo "firejail --private="${PWD}" winecfg

#tofix:use firejail
#echo "firejail --private="${PWD}" wine "${starterProg}"

cd .wine${numofbits}/dosdevices

cd ../../

cd "$(dirname "${starterProg}")"

#echo ">>>>$PWD"
#echo ">>>$(basename "${starterProg}")"
#echo ">>>${WINEPREFIX}"
#echo ">>>${WINEARCH}"

sleep 1

#echo "${PWD}/$(basename "${starterProg}")"

#echo ">>>${thepwd}"
#echo "$(basename "${starterProg}")"
#echo "$PWD"



autoorloadselect="$(eval zenity --list --radiolist --column \"Selection\" --column \"Select\" TRUE \"Auto-Load\" FALSE \"Open To View\")"

if [ "$autoorloadselect" = "Auto-Load" ]; then

	winepathStarterprogA="$(echo "${PWD}" | sed "s#${thepwd}##g" | sed "s#/#\\\#g")\\\\"
	#echo "${winepathStarterprogA}"
	winepathStarterprog='z:\'
	winepathStarterprog="${winepathStarterprog}${winepathStarterprogA}$(basename "${starterProg}")"
	#echo "$winepathStarterprog"

	if [ "$usesandwine" = "true" ]; then
		if [ "$(oldwhich wine32)" != "" ]; then
			WINEPREFIX="${thepwd}/.wine${numofbits}" WINEARCH=win${numofbits} HOME="${thepwd}" sandwine ${sandnetworkoption} --pulseaudio --x11 --dotwine "${thepwd}/.wine${numofbits}:rw" --pass "${thepwd}/.dosbox:ro" --pass "${thepwd}/.cache/wine:rw" --pass "${thepwd}/EXE:ro" -- "${winepathStarterprog}"
		else
			WINEPREFIX="${thepwd}/.wine${numofbits}" HOME="${thepwd}" sandwine ${sandnetworkoption} --pulseaudio --x11 --dotwine "${thepwd}/.wine${numofbits}:rw" --pass "${thepwd}/.dosbox:ro" --pass "${thepwd}/.cache/wine:rw" --pass "${thepwd}/EXE:ro" -- "${winepathStarterprog}"
		fi
	else


		if [ "$(oldwhich wine32)" != "" ]; then
			WINEPREFIX="${thepwd}/.wine${numofbits}" WINEARCH="win${numofbits}" wine "${winepathStarterprog}"
		else
			WINEPREFIX="${thepwd}/.wine${numofbits}" wine "${winepathStarterprog}"
		fi
	fi
else
	if [ "$usesandwine" = "true" ]; then
		if [ "$(oldwhich wine32)" != "" ]; then
			WINEPREFIX="${thepwd}/.wine${numofbits}" HOME="${thepwd}" WINEARCH=win${numofbits} sandwine ${sandnetworkoption} --pulseaudio --x11 --dotwine ${thepwd}/.wine${numofbits}/:rw --pass "${thepwd}/.dosbox:ro" --pass "${thepwd}/.cache/wine:rw" --pass "${thepwd}/EXE:ro" -- "Z:\\"
		else
			WINEPREFIX="${thepwd}/.wine${numofbits}" HOME="${thepwd}" sandwine ${sandnetworkoption} --pulseaudio --x11 --dotwine ${thepwd}/.wine${numofbits}/:rw --pass "${thepwd}/.dosbox:ro" --pass "${thepwd}/.cache/wine:rw" --pass "${thepwd}/EXE:ro" -- "Z:\\"
		fi
	else
		WINEPREFIX="${thepwd}/.wine${numofbits}" wine "Z:\\"
	fi
fi



sleep 5

while [ "$(ps aux | grep [w]ineserver)" != "" ]; do
sleep 5
done

sleep 3

#firejail --quiet --private="${thepwd}" --private-cwd="/home/$(whoami)/$(dirname "${starterProg}")" --env=WINEPREFIX=/home/$(whoami)/.wine${numofbits} --env=WINEARCH=win${numofbits} sh -c "wine "$(basename "${starterProg}")""

umask "${OLD_UMASK}"
