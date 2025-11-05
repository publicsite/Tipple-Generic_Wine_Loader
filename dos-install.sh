#!/bin/sh

OLD_UMASK="$(umask)"
umask 0022

if [ "$(which zenity)" = "" ]; then
	echo "You need to install zenity to proceed."
	exit
fi

if [ "$(which dosbox)" = "" ]; then
	echo "You need to install dosbox to proceed."
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

if [ -L "${thepwd}/${themountpoint}" ]; then
	rm "${thepwd}/${themountpoint}"
fi
if ! [ -d "${thepwd}/${themountpoint}" ]; then
	sudo mkdir -p "${thepwd}/${themountpoint}"
fi

dosboxConf="$(find $HOME/.dosbox -type f -name "dosbox*.conf" 2>/dev/null)"

if [ ! -f "${dosboxConf}" ]; then
	dosbox -c "exit"
fi

dosboxConf="$(find $HOME/.dosbox -type f -name "dosbox*.conf" 2>/dev/null)"

if [ ! -f "${dosboxConf}" ]; then
	printf "DosBox configuration file not found and could not be generated, exiting."
	exit
fi

sudo mount "/$(cdemu device-mapping | head -n 3 | tail -n 1 | cut -d / -f 2- | cut -d ' ' -f 1)" "${thepwd}/${themountpoint}"


if [ ! -d "$thepwd/dos_c_drive" ]; then 
mkdir "$thepwd/dos_c_drive"
fi

pathToEXE=""

while true; do
	pathToEXE="$(zenity --title="Select an EXE file in the cdrom directory" --file-selection --filename="${thepwd}/${themountpoint}/setup.exe")"
echo ${pathToEXE} | rev | cut -c 1-4
	if [ "$(echo ${pathToEXE} | rev | cut -c 1-4 )" != "exe." ] && [ "$(echo ${pathToEXE} | rev | cut -c 1-4 )" != "EXE." ] && [ "$(echo ${pathToEXE} | rev | cut -c 1-4 )" != "tab." ] && [ "$(echo ${pathToEXE} | rev | cut -c 1-4 )" != "TAB." ]; then
			zenity --error --title "Error" --text "Please select an EXE file in the cdrom directory"
			#clean up
			sudo umount "${thepwd}/${themountpoint}"
			cdemu unload all
			exit
	else
		if [ "$(printf "%s" "${pathToEXE}" | grep -o "^${thepwd}/${themountpoint}.*")" = "" ]; then
			zenity --error --title "Error" --text "Please select an EXE file in the cdrom directory"
			#clean up
			sudo umount "${thepwd}/${themountpoint}"
			cdemu unload all
			exit
		fi
		break;
	fi
done

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
#if [ "$(grep -o "^output=.*$" "${thepwd}/$(basename ${dosboxConf})")" != "" ]; then
#	sed -i "s#^output=.*#output=opengl#g" "${thepwd}/$(basename ${dosboxConf})"
#else
#	printf "output=opengl\n" >> "${thepwd}/$(basename ${dosboxConf})"
#fi

printf "\n" >> "${thepwd}/$(basename ${dosboxConf})"
printf "MOUNT C %s\n" "$thepwd/dos_c_drive" >> "${thepwd}/$(basename ${dosboxConf})"
printf "MOUNT D %s -t cdrom\n" "$thepwd/${themountpoint}" >> "${thepwd}/$(basename ${dosboxConf})"
printf "D:\n" >> "${thepwd}/$(basename ${dosboxConf})"

thelength="$(expr length "${thepwd}/${themountpoint}")"
dosPathToEXE="$(printf "%s" "${pathToEXE}" | cut -c $thelength- | cut -c 3- | sed 's#/#\\#g' )"

printf "D:\\%s\n" "${dosPathToEXE}" >> "${thepwd}/$(basename ${dosboxConf})"
printf "exit\n" "${dosPathToEXE}" >> "${thepwd}/$(basename ${dosboxConf})"

dosbox -conf "${thepwd}/$(basename ${dosboxConf})"

while [ "$(ps aux | grep [d]osbox)" != "" ]; do
sleep 5
done

sleep 3

sudo umount "${thepwd}/${themountpoint}"
cdemu unload all

umask "${OLD_UMASK}"
