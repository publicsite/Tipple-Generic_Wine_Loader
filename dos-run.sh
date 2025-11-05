#!/bin/sh

OLD_UMASK="$(umask)"
umask 0022

if [ "$(which zenity)" = "" ]; then
	echo "You need to install zenity to proceed."
	exit
fi

if [ "$(which dosbox)" = "" ]; then
	echo "You need to install wine to proceed."
	exit
fi

if [ "$(which cdemu)" = "" ]; then
	echo "You need to install cdemu to proceed."
	exit
fi




cd "$(dirname ${0})"

thepwd="${PWD}"

themountpoint="mountpoint"

dosboxConf="$(find $HOME/.dosbox -type f -name "dosbox*.conf" 2>/dev/null)"

if [ ! -f "${dosboxConf}" ]; then
	dosbox -c "exit"
fi

dosboxConf="$(find $HOME/.dosbox -type f -name "dosbox*.conf" 2>/dev/null)"

if [ ! -f "${dosboxConf}" ]; then
	printf "DosBox configuration file not found and could not be generated, exiting."
	exit
fi

cp -a "${dosboxConf}" "${thepwd}"

##unfortunately fulllscreen is too slow even with opengl
#if [ "$(grep -o "^fullscreen=.*$" "${thepwd}/$(basename ${dosboxConf})")" != "" ]; then
#	sed -i "s#^fullscreen=.*#fullscreen=true#g" "${thepwd}/$(basename ${dosboxConf})"
#else
#	printf "fullscreen=true\n" >> "${thepwd}/$(basename ${dosboxConf})"
#fi
#if [ "$(grep -o "^output=.*$" "${thepwd}/$(basename ${dosboxConf})")" != "" ]; then
#	sed -i "s#^fulldouble=.*#fulldouble=false#g" "${thepwd}/$(basename ${dosboxConf})"
#else
#	printf "fulldouble=false\n" >> "${thepwd}/$(basename ${dosboxConf})"
#fi
#
#if [ "$(grep -o "^output=.*$" "${thepwd}/$(basename ${dosboxConf})")" != "" ]; then
#	sed -i "s#^output=.*#output=opengl#g" "${thepwd}/$(basename ${dosboxConf})"
#else
#	printf "output=opengl\n" >> "${thepwd}/$(basename ${dosboxConf})"
#fi

printf "\n" >> "${thepwd}/$(basename ${dosboxConf})"
printf "MOUNT C %s\n" "$thepwd/dos_c_drive" >> "${thepwd}/$(basename ${dosboxConf})"
printf "MOUNT D %s -t cdrom\n" "$thepwd/${themountpoint}" >> "${thepwd}/$(basename ${dosboxConf})"

numofbits=""

if [ "$(echo "${winedir}" | rev | cut -c 1-2)" = "23" ]; then
	numofbits="32"
else
	numofbits="64"
fi

cdemu dpm-emulation 0 1
cdemu bad-sector-emulation 0 1

cdemu unload all
sleep 2
cdemu load 0 "$(find ISO/1 -type f -name "*.iso" | head -n 1)"
sleep 2
sudo mkdir -p "${PWD}/mountpoint"
sudo mount "/$(cdemu device-mapping | head -n 3 | tail -n 1 | cut -d / -f 2- | cut -d ' ' -f 1)" "${PWD}/mountpoint"


	listOfLNKs="$(find "${thepwd}/dos_c_drive/users/$(whoami)/Desktop" -type f -name "*.lnk")"

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


		thelength="$(expr length "${winedir}/drive_c/users/$(whoami)/Desktop")"
		thepath="$(printf "%s" "${thepath}" | cut -c $thelength- | cut -c 2- | sed 's#/#\\#g' )"

		thepath="C:\\users\\$(whoami)\\Desktop\\${thepath}"
		echo "$thepath"
		sleep 2

		#todo: add firejail
		#firejail --private="${PWD}" wine start "$thepath"
		dosbox -fullscreen -c "${thepath}" -conf "${thepwd}/${basename dosboxConf}"
	else

		pathToEXE=""

		while true; do
			pathToEXE="$(zenity --title="Select an EXE or BAT file in the cdrom or drive C" --file-selection --filename="${thepwd}/dos_c_drive/somefile.exe")"
		echo ${pathToEXE} | rev | cut -c 1-4
			if [ "$(printf "%s" "${pathToEXE}" | rev | cut -c 1-4 )" != "exe." ] && [ "$(printf "%s" "${pathToEXE}" | rev | cut -c 1-4 )" != "EXE." ] && [ "$(printf "%s" "${pathToEXE}" | rev | cut -c 1-4 )" != "tab." ] && [ "$(printf "%s" "${pathToEXE}" | rev | cut -c 1-4 )" != "TAB." ]; then
					zenity --error --title "Error" --text "Please select an EXE file in the cdrom or drive C"
			else

				if [ "$(printf "%s" "${pathToEXE}" | grep -o "^${thepwd}/${themountpoint}.*")" = "" ]; then
					if [ "$(printf "%s" "${pathToEXE}" | grep -o "^${thepwd}/dos_c_drive")" = "" ]; then
						zenity --error --title "Error" --text "Please select an EXE or BAT file in cdrom or drive C"
						#clean up
						sudo umount "${PWD}/mountpoint"
						cdemu unload all
						sudo rmdir "${PWD}/mountpoint"
						exit
					fi
				fi
				
				break;
			fi
		done

		if [ "$(printf "%s" "${pathToEXE}" | grep -o "^${thepwd}/${themountpoint}")" != "" ]; then
			thelength="$(expr length "${thepwd}/${themountpoint}")"
			dosPathToEXE="$(printf "%s" "${pathToEXE}" | cut -c $thelength- | cut -c 3- | sed 's#/#\\#g' )"

			echo "PATH ${dosPathToEXE}"

			printf "D:\n" >> "${thepwd}/$(basename ${dosboxConf})"
			printf "cd D:\\\n" >> "${thepwd}/$(basename ${dosboxConf})"

			printf "D:\\%s\n" "${dosPathToEXE}" >> "${thepwd}/$(basename ${dosboxConf})"

			printf "exit\n" >> "${thepwd}/$(basename ${dosboxConf})"

			dosbox -conf "${thepwd}/$(basename ${dosboxConf})"
		elif [ "$(printf "%s" "${pathToEXE}" | grep -o "^${thepwd}/dos_c_drive")" != "" ]; then
			thelength="$(expr length "${thepwd}/dos_c_drive")"

			dosPathContainingEXE="$(printf "%s" "$(dirname ${pathToEXE})" | cut -c $thelength- | cut -c 3- | sed 's#/#\\#g' )"
			dosPathToEXE="$(printf "%s" "${pathToEXE}" | cut -c $thelength- | cut -c 3- | sed 's#/#\\#g' )"

			printf "C:\n" >> "${thepwd}/$(basename ${dosboxConf})"
	
			#printf "cd D:\\\n" >> "${thepwd}/$(basename ${dosboxConf})"

			printf "cd C:\\%s\n" "${dosPathContainingEXE}" >> "${thepwd}/$(basename ${dosboxConf})"

			printf "C:\\%s\n" "${dosPathToEXE}" >> "${thepwd}/$(basename ${dosboxConf})"

			printf "exit\n" >> "${thepwd}/$(basename ${dosboxConf})"
			dosbox -conf "${thepwd}/$(basename ${dosboxConf})"
		fi

	fi

sleep 5

while [ "$(ps aux | grep [d]osbox)" != "" ]; do
sleep 5
done

sleep 3

sudo umount "${PWD}/mountpoint"
cdemu unload all
sudo rmdir "${PWD}/mountpoint"

umask "${OLD_UMASK}"
