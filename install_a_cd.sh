#!/bin/sh

OLD_UMASK="$(umask)"
umask 0022

cd "$(dirname ${0})"

if [ ! -d "$HOME/WINEHOMES" ]; then
mkdir $HOME/WINEHOMES
fi

if [ ! -d "$HOME/WINEHOMES/WINE_SKELETON" ]; then
mkdir $HOME/WINEHOMES/WINE_SKELETON
fi

if [ ! -d "$HOME/WINEHOMES/mountpoint" ]; then
mkdir $HOME/WINEHOMES/WINE_SKELETON/mountpoint
fi


pathToISO=""

dosOrWine="$(eval zenity --list --radiolist --column \"Selection\" --column \"Type\" TRUE Wine FALSE DOS)"

while true; do
	pathToISO="$(zenity --title="Select an ISO file" --file-selection)"
echo ${pathToISO} | rev | cut -c 1-4
	if [ "$(echo ${pathToISO} | rev | cut -c 1-4 )" != "osi." ] && [ "$(echo ${pathToISO} | rev | cut -c 1-4 )" != "OSI." ]; then
		zenity --error --title "Error" --text "Please select an ISO file"
	else
		break;
	fi
done

nameOfISO="$(basename "${pathToISO}")"

mkdir -p ISOs

nameOfISO="${nameOfISO%????}"

nameOfISO="$(zenity --entry --entry-text="${nameOfISO}" --text "Type the name of your application")"

if [ ! -d "$HOME/WINEHOMES/${nameOfISO}" ]; then
	mkdir "$HOME/WINEHOMES/${nameOfISO}"
fi

if [ ! -d "$HOME/WINEHOMES/${nameOfISO}/ISO" ]; then
	mkdir "$HOME/WINEHOMES/${nameOfISO}/ISO"
fi

#echo "${pathToISO}" >> $HOME/WINEHOMES/${nameOfISO}/disks.txt

isoindex=1

if [ ! -d "$HOME/WINEHOMES/${nameOfISO}/ISO/${isoindex}" ]; then
	mkdir "$HOME/WINEHOMES/${nameOfISO}/ISO/${isoindex}"
fi

ln "${pathToISO}" "$HOME/WINEHOMES/${nameOfISO}/ISO/${isoindex}/"

pathToISO="$HOME/WINEHOMES/${nameOfISO}/ISO/${isoindex}"

yesno=0
while true; do
	zenity --question --title "Alert" --text "Would you like to add another CD for this application"
	if [ "$?" = "0" ]; then
		#read path to iso
		#echo "${pathToISO}" >> $HOME/WINEHOMES/${nameOfISO}/disks.txt

		while true; do
		pathToISO="$(zenity --title="Select an ISO file" --file-selection)"
		echo ${pathToISO} | rev | cut -c 1-4
			if [ "$(echo ${pathToISO} | rev | cut -c 1-4 )" != "osi." ] && [ "$(echo ${pathToISO} | rev | cut -c 1-4 )" != "OSI." ]; then
				zenity --error --title "Error" --text "Please select an ISO file"
			else
				break;
			fi
		done

		isoindex="$(expr ${isoindex} + 1)"

		if [ ! -d "$HOME/WINEHOMES/${nameOfISO}/ISO/${isoindex}" ]; then
			mkdir "$HOME/WINEHOMES/${nameOfISO}/ISO/${isoindex}"
		fi

		ln "${pathToISO}" "$HOME/WINEHOMES/${nameOfISO}/ISO/${isoindex}/"
	else
		break;
	fi
done
 
##write run shell script

if [ "${dosOrWine}" = "DOS" ]; then

	cp -a dos-install.sh "$HOME/WINEHOMES/${nameOfISO}/install.sh"
	chmod +x "$HOME/WINEHOMES/${nameOfISO}/install.sh"

	cp -a dos-run.sh "$HOME/WINEHOMES/${nameOfISO}/run.sh"
	chmod +x "$HOME/WINEHOMES/${nameOfISO}/run.sh"
elif [ "${dosOrWine}" = "Wine" ]; then

	cp -a wine-install.sh "$HOME/WINEHOMES/${nameOfISO}/install.sh"
	chmod +x "$HOME/WINEHOMES/${nameOfISO}/install.sh"

	cp -a wine-run.sh "$HOME/WINEHOMES/${nameOfISO}/run.sh"
	chmod +x "$HOME/WINEHOMES/${nameOfISO}/run.sh"
fi


cp -a load_secondary_cd.sh "$HOME/WINEHOMES/${nameOfISO}/"
chmod +x "$HOME/WINEHOMES/${nameOfISO}/load_secondary_cd.sh"

cp -a config_wine.sh "$HOME/WINEHOMES/${nameOfISO}/"
chmod +x "$HOME/WINEHOMES/${nameOfISO}/config_wine.sh"

#yesno=0
#yesno="$(zenity --question --title "Alert" --text "Would you like to try and run autorun.exe?")"
#if [ "$yesno" = "1" ]; then
#
#	cd "$HOME/WINEHOMES/${nameOfISO}"
#	./run.sh
#fi

umask "${OLD_UMASK}"
