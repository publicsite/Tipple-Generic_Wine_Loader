#!/bin/sh


if [ "$(which zenity)" = "" ]; then
	echo "You need to install zenity to proceed."
	exit
fi

if [ "$(which wine)" = "" ]; then
	echo "You need to install wine to proceed."
	exit
fi

if [ "$(which winecfg)" = "" ]; then
	echo "You need to install winecfg to proceed."
	exit
fi

if [ "$(which winetricks)" = "" ]; then
	echo "You need to install winetricks to proceed."
	exit
fi

if [ "$(which cdemu)" = "" ]; then
	echo "You need to install cdemu to proceed."
	exit
fi


cd "$(dirname ${0})"

thepwd="${PWD}"

cdemu dpm-emulation 0 1
cdemu bad-sector-emulation 0 1
cdemu unload all
sleep 2

firstpath="$(find "$PWD/ISO/1" -maxdepth 1 -type f)"
cdemu load 0 "${firstpath}"
sleep 2


themountpoint="mountpoint"

if [ -L "${themountpoint}" ]; then
	rm "${themountpoint}"
fi
if ! [ -d "${themountpoint}" ]; then
	sudo mkdir -p "${themountpoint}"
fi




sudo mount "/$(cdemu device-mapping | head -n 3 | tail -n 1 | cut -d / -f 2- | cut -d ' ' -f 1)" "${themountpoint}"
sleep 2
theAutoRun="$(find "${themountpoint}" -iname "AUTORUN.INF")"

starterProg="${themountpoint}/$(grep "OPEN=" "${theAutoRun}" | cut -d '=' -f 2 | rev | cut -d ',' -f 1 | rev | cut -d ' ' -f 1 | tr -d '\\\r' | tr '\' '/' | rev | cut -d ',' -f 1 | rev)"

if [ "$starterProg" = "${themountpoint}" ] || [ "$starterProg" = "${themountpoint}/" ]; then
	starterProg="${themountpoint}/$(grep "open=" "${theAutoRun}" | cut -d '=' -f 2 | rev | cut -d ',' -f 1 | rev | cut -d ' ' -f 1 | tr -d '\\\r' | tr '\' '/' | rev | cut -d ',' -f 1 | rev)"
fi

if [ "$starterProg" = "${themountpoint}" ] || [ "$starterProg" = "${themountpoint}/" ]; then
	starterProg="${themountpoint}/$(grep "Open=" "${theAutoRun}" | cut -d '=' -f 2 | rev | cut -d ',' -f 1 | rev | cut -d ' ' -f 1 | tr -d '\\\r' | tr '\' '/')"
fi

if [ "$starterProg" = "${themountpoint}" ] || [ "$starterProg" = "${themountpoint}/" ]; then

	starterProg="$(find "$(dirname "${starterProg}")" -maxdepth 1 -iname "$(basename "${starterProg}")")"

	#Handle "Sold Out Software"
	if [ "$(basename "$starterProg" | tr '[:upper:]' '[:lower:]')" = "setup.now.exe" ]; then
		starterProg="$(find "${themountpoint}" -maxdepth 1 -type d -iname "SETUP")"
		if [ "$starterProg" = "" ]; then
			starterProg="${themountpoint}"
		fi
		starterProg="$(find "${starterProg}" -maxdepth 1 -type f -iname "SETUP.EXE")"
	fi

fi

if [ ! -f "mountpoint/$starterProg" ]; then
	starterProg="$(find "${themountpoint}" -type f -iname "$(basename "${starterProg}")")"
fi

if [ ! -f "${starterProg}" ]; then
	starterProg="$(find "${themountpoint}" -maxdepth 1 -type f -iname "setup.exe")"
fi

if [ ! -f "${starterProg}" ]; then
	starterProg="$(find "${themountpoint}" -maxdepth 1 -type f -iname "install.exe")"
fi

if [ ! -f "${starterProg}" ]; then
	toTest="$(find "${themountpoint}" -maxdepth 1 -type f -iname "*.exe")"
	if [ "$(printf "%s\n" "$toTest" | wc -l)" = "1" ]; then
		starterProg="$toTest"
	fi
fi

if [ ! -f "${starterProg}" ]; then
	starterProg="$(find "${themountpoint}" -mindepth 2 -type f -iname "setup.exe" | sort -d | head -n 1)"
fi

if [ "$(file "$starterProg" | grep "64")" = "" ]; then
	numofbits=32
else
	numofbits=64
fi

export WINEARCH="win${numofbits}"

if [ ! -d "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}" ]; then
	zenity --info --title="Please make 'generic' wine config." --text="Set your default version of Windoze."
	export WINEPREFIX="${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}"
	winecfg
	winetricks

#We don't want to use the Z drive!
rm "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/AppData/Roaming/Microsoft/Windows/Templates"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/AppData/Roaming/Microsoft/Windows/Templates"
rm "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/Pictures"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/Pictures"
rm "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/Videos"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/Videos"
rm "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/Desktop"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/Desktop"
rm "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/Downloads"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/Downloads"
rm "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/Music"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/Music"
rm "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/Documents"
mkdir "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/drive_c/users/$(whoami)/Documents"
rm "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}/dosdevices/z:"

fi

if [ ! -d "${PWD}/.wine${numofbits}" ]; then
	cp -a "${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}" "${PWD}/"
fi

export WINEPREFIX="${PWD}/.wine${numofbits}"

yesno=0
while true; do
	zenity --question --title "Alert" --text "Would you like to run winecfg and winetricks for this application specifically?"
	if [ "$?" = "0" ]; then
		winecfg
		winetricks
		break;
	else
		break;
	fi
done







##echo "mkdir -p /tmp/overlay "${PWD}/.wine${numofbits}" "${PWD}/.wine${numofbits}_modifications"
##echo "sudo mount -t overlay overlay -o lowerdir="${HOME}/WINEHOMES/WINE_SKELETON/.wine${numofbits}",upperdir="${PWD}/.wine${numofbits}_modifications",workdir="${PWD}/.wine${numofbits}" "${PWD}/.wine${numofbits}"

#tofix:use firejail
#echo "firejail --private="${PWD}" winecfg

#tofix:use firejail
#echo "firejail --private="${PWD}" wine "${starterProg}"

cd .wine${numofbits}/dosdevices
if [ -L d: ]; then
rm d:
fi
ln -s ../../mountpoint d:
if [ -L d:: ]; then
rm d::
fi
ln -s "/$(cdemu device-mapping | head -n 3 | tail -n 1 | cut -d / -f 2- | cut -d ' ' -f 1)" d::
cd ../../

cd "${thepwd}/$(dirname "${starterProg}")"

#echo ">>>>$PWD"
#echo ">>>$(basename "${starterProg}")"
#echo ">>>${WINEPREFIX}"
#echo ">>>${WINEARCH}"

sleep 1

echo "${PWD}/$(basename "${starterProg}")"


autoorloadselect="$(eval zenity --list --radiolist --column \"Selection\" --column \"Select\" TRUE \"Auto-Load\" FALSE \"Open To View\")"

if [ "$autoorloadselect" = "Auto-Load" ]; then
	wine "$(basename "${starterProg}")"
else
	wine "D:\\"
fi



sleep 5

while [ "$(ps aux | grep [w]ineserver)" != "" ]; do
sleep 5
done

sleep 3

#firejail --quiet --private="${thepwd}" --private-cwd="/home/$(whoami)/$(dirname "${starterProg}")" --env=WINEPREFIX=/home/$(whoami)/.wine${numofbits} --env=WINEARCH=win${numofbits} sh -c "wine "$(basename "${starterProg}")""

sudo umount "${thepwd}/${themountpoint}"
cdemu unload all

