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

winedir="$(find . -maxdepth 1 -type d -name ".wine*")"

numofbits=""

if [ "$(echo "${winedir}" | rev | cut -c 1-2)" = "23" ]; then
	numofbits="32"
else
	numofbits="64"
fi

export WINEPREFIX="${PWD}/$(echo "${winedir}" | cut -c 3-)"
export WINEARCH="win${numofbits}"

cdemu dpm-emulation 0 1
cdemu bad-sector-emulation 0 1

cdemu unload all
sleep 2
cdemu load 0 "$(find ISO/1 -type f -name "*.iso" | head -n 1)"
sleep 2
sudo mkdir -p "${PWD}/mountpoint"
sudo mount "/$(cdemu device-mapping | head -n 3 | tail -n 1 | cut -d / -f 2- | cut -d ' ' -f 1)" "${PWD}/mountpoint"

rm "${PWD}/.wine${numofbits}/dosdevices/d:"
rm "${PWD}/.wine${numofbits}/dosdevices/d::"
cd .wine${numofbits}/dosdevices
ln -s "${thepwd}/mountpoint" "d:"
ln -s "/$(cdemu device-mapping | head -n 3 | tail -n 1 | cut -d / -f 2- | cut -d ' ' -f 1)" "d::"
cd ../../


if [ -d "${winedir}/drive_c/ProgramData/Microsoft/Windows/Start Menu" ]; then

	listOfLNKs="$(find "${winedir}/drive_c/ProgramData/Microsoft/Windows/Start Menu" -type f -name "*.lnk")"

	if [ "$listOfLNKs" = "" ]; then
		listOfLNKs="$(find "${winedir}/drive_c/users/$(whoami)/AppData/Roaming" -type f -name "*.lnk")"
	fi

	if [ "$listOfLNKs" = "" ]; then
		listOfLNKs="$(find "${winedir}/drive_c/users/$(whoami)/Desktop" -type f -name "*.lnk")"
	fi

	if [ "$listOfLNKs" != "" ]; then

		baseLNKs=""

		checked=""

		old_IFS="$IFS"
		export IFS="
"
		for aLNK in $listOfLNKs; do
			if [ "$baseLNKs" = "" ]; then
				baseLNKs="FALSE \"$aLNK\""
			else
				baseLNKs="${baseLNKs} FALSE \"$aLNK\""
			fi
		done
export IFS="$old_IFS"
echo "eval zenity --list --radiolist --column \"Selection\" --column \"lnk\" ${checked} ${baseLNKs}"
		selection="$(eval zenity --list --radiolist --column \"Selection\" --column \"lnk\" ${baseLNKs})"

		#todo: add firejail
		#thepath="$(firejail --private="${PWD}" winepath --windows "$selection" | grep -o "ProgramData.*")" #work around for broken /unix argument to wine start
		thepath="$(winepath --windows "$selection" | grep -o "ProgramData.*")" #work around for broken /unix argument to wine start
		if [ "${thepath}" = "" ]; then
			thepath="$(winepath --windows "$selection" | grep -o "users.*")" #work around for broken /unix argument to wine start
		fi

		thepath="C:\\${thepath}"
		echo "$thepath"
		sleep 2

		#todo: add firejail
		#firejail --private="${PWD}" wine start "$thepath"
		wine start "$thepath"
	fi
fi

sleep 5

while [ "$(ps aux | grep [w]ineserver)" != "" ]; do
sleep 5
done

sudo umount "${PWD}/mountpoint"
cdemu unload all
sudo rmdir "${PWD}/mountpoint"
