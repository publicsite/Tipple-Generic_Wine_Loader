#!/bin/sh

oldwhich(){
	aresult="$(which "$1")"
	retval="$?"
	if [ "retval" = "0" ]; then
		echo "$aresult"
		return 0
	else
		return $retval
	fi
}

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

if [ ! -d "$HOME/WINEHOMES/WINE_SKELETON/fakehome" ]; then
	mkdir "$HOME/WINEHOMES/WINE_SKELETON/fakehome"
fi

if [ ! -d "$HOME/WINEHOMES/WINE_SKELETON/fakehome/.dosbox" ]; then
	if [ -d "$HOME/.dosbox" ]; then
		cp -a "$HOME/.dosbox" "$HOME/WINEHOMES/WINE_SKELETON/fakehome/.dosbox"
	else
		mkdir -p "$HOME/WINEHOMES/WINE_SKELETON/fakehome/.dosbox"
	fi
fi

if [ ! -d "$HOME/WINEHOMES/WINE_SKELETON/fakehome/.cache/wine" ]; then
	if [ -d "$HOME/.cache/wine" ]; then
		mkdir -p "$HOME/WINEHOMES/WINE_SKELETON/fakehome/.cache"
		cp -a "$HOME/.cache/wine" "$HOME/WINEHOMES/WINE_SKELETON/fakehome/.cache"
	else
		mkdir -p "$HOME/WINEHOMES/WINE_SKELETON/fakehome/.cache/wine"
	fi
fi


if [ "$(which wine)" = "" ]; then
	echo "You need to install wine to proceed."
	exit
fi

usesandwine="true"
usenetworking="true"
#if [ "$(wine --version 2>/dev/null | cut -d . -f1)" = "wine-10" ]; then
#	echo "WARNING: Firejail is not supported using your version of wine!"
#	usesandwine="false"
#fi

pathToISO=""

dosOrWine="$(eval zenity --list --radiolist --column \"Selection\" --column \"Type\" TRUE Wine FALSE DOS)"

while true; do
	pathToISO="$(zenity --title="Select an ISO file" --file-selection)"
#echo ${pathToISO} | rev | cut -c 1-4
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

if [ ! -d "$HOME/WINEHOMES/${nameOfISO}/fakehome" ]; then
	mkdir "$HOME/WINEHOMES/${nameOfISO}/fakehome"
fi

if [ ! -d "$HOME/WINEHOMES/${nameOfISO}/fakehome/ISO" ]; then
	mkdir "$HOME/WINEHOMES/${nameOfISO}/fakehome/ISO"
fi

if [ ! -d "$HOME/WINEHOMES/${nameOfISO}/fakehome/.dosbox" ]; then
	if [ -d "$HOME/WINEHOMES/${WINE_SKELETON}/fakehome/.dosbox" ]; then
		cp -a "$HOME/WINEHOMES/${WINE_SKELETON}/fakehome/.dosbox" "$HOME/WINEHOMES/${nameOfISO}/fakehome/.dosbox"
	else
		mkdir -p "$HOME/WINEHOMES/${nameOfISO}/fakehome/.dosbox"
	fi
fi

if [ ! -d "$HOME/WINEHOMES/${nameOfISO}/fakehome/.cache/wine" ]; then
	if [ -d "$HOME/WINEHOMES/WINE_SKELETON/fakehome/.cache/wine" ]; then
		mkdir -p "$HOME/WINEHOMES/${nameOfISO}/fakehome/.cache"
		cp -a  "$HOME/WINEHOMES/WINE_SKELETON/fakehome/.cache/wine" "$HOME/WINEHOMES/${nameOfISO}/fakehome/.cache/wine"
	else
		mkdir -p "$HOME/WINEHOMES/${nameOfISO}/fakehome/.cache/wine"
	fi
fi

#echo "${pathToISO}" >> $HOME/WINEHOMES/${nameOfISO}/disks.txt

isoindex=1

if [ ! -d "$HOME/WINEHOMES/${nameOfISO}/fakehome/ISO/${isoindex}" ]; then
	mkdir "$HOME/WINEHOMES/${nameOfISO}/fakehome/ISO/${isoindex}"
fi

ln "${pathToISO}" "$HOME/WINEHOMES/${nameOfISO}/fakehome/ISO/${isoindex}/"

pathToISO="$HOME/WINEHOMES/${nameOfISO}/fakehome/ISO/${isoindex}"

yesno=0
while true; do
	zenity --question --title "Alert" --text "Would you like to add another CD for this application"
	if [ "$?" = "0" ]; then
		#read path to iso
		#echo "${pathToISO}" >> $HOME/WINEHOMES/${nameOfISO}/disks.txt

		while true; do
		pathToISO="$(zenity --title="Select an ISO file" --file-selection)"
		#echo ${pathToISO} | rev | cut -c 1-4
			if [ "$(echo ${pathToISO} | rev | cut -c 1-4 )" != "osi." ] && [ "$(echo ${pathToISO} | rev | cut -c 1-4 )" != "OSI." ]; then
				zenity --error --title "Error" --text "Please select an ISO file"
			else
				break;
			fi
		done

		isoindex="$(expr ${isoindex} + 1)"

		if [ ! -d "$HOME/WINEHOMES/${nameOfISO}/ISO/${isoindex}" ]; then
			mkdir "$HOME/WINEHOMES/${nameOfISO}/fakehome/ISO/${isoindex}"
		fi

		ln "${pathToISO}" "$HOME/WINEHOMES/${nameOfISO}/fakehome/ISO/${isoindex}/"
	else
		break;
	fi
done
 
##write run shell script

if [ "${dosOrWine}" = "DOS" ]; then

	cp -a dos-install-iso.sh "$HOME/WINEHOMES/${nameOfISO}/install.sh"
	chmod +x "$HOME/WINEHOMES/${nameOfISO}/install.sh"

	cp -a dos-run-iso.sh "$HOME/WINEHOMES/${nameOfISO}/run.sh"
	chmod +x "$HOME/WINEHOMES/${nameOfISO}/run.sh"
elif [ "${dosOrWine}" = "Wine" ]; then

	cp -a wine-install-iso.sh "$HOME/WINEHOMES/${nameOfISO}/install.sh"
	chmod +x "$HOME/WINEHOMES/${nameOfISO}/install.sh"

	cp -a wine-run-iso.sh "$HOME/WINEHOMES/${nameOfISO}/run.sh"
	chmod +x "$HOME/WINEHOMES/${nameOfISO}/run.sh"
fi


if zenity --question --text="Would you like to use sandboxing?"; then
	usesandwine="true"
	if zenity --question --text="Would you like to enable networking?"; then
		usenetworking="true"
	else
		usenetworking="false"
	fi
else
	usesandwine="false"
fi

#change the installer and runner not to use firejail if usesandwine is set to false from install_a_cd (this) script {
if [ "$usesandwine" = "false" ]; then
	sed -i 's#usesandwine="true"#usesandwine="false"#g' "$HOME/WINEHOMES/${nameOfISO}/install.sh"
fi

if [ "$usesandwine" = "false" ]; then
	sed -i 's#usesandwine="true"#usesandwine="false"#g' "$HOME/WINEHOMES/${nameOfISO}/run.sh"
fi
# }

#change the installer and runner not to use networking if usesandwine is set to false from install_a_cd (this) script {
if [ "$usenetworking" = "false" ]; then
	sed -i 's#usenetworking="true"#usenetworking="false"#g' "$HOME/WINEHOMES/${nameOfISO}/install.sh"
fi

if [ "$usenetworking" = "false" ]; then
	sed -i 's#usenetworking="true"#usenetworking="false"#g' "$HOME/WINEHOMES/${nameOfISO}/run.sh"
fi
# }

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
