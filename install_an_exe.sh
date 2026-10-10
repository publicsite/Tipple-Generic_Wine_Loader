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

usesandwine="false"
usenetworking="false"
#if [ "$(wine --version 2>/dev/null | cut -d . -f1)" = "wine-10" ]; then
#	echo "WARNING: Firejail is not supported using your version of wine!"
#	usesandwine="false"
#fi

pathToEXE=""

dosOrWine="$(eval zenity --list --radiolist --column \"Selection\" --column \"Type\" TRUE Wine FALSE DOS)"

while true; do
	pathToEXE="$(zenity --title="Select an EXE file" --file-selection)"
#echo ${pathToEXE} | rev | cut -c 1-4
	if [ "$(echo ${pathToEXE} | rev | cut -c 1-4 )" != "exe." ] && [ "$(echo ${pathToEXE} | rev | cut -c 1-4 )" != "EXE." ]; then
		zenity --error --title "Error" --text "Please select an EXE file"
	else
		break;
	fi
done

nameOfEXE="$(basename "${pathToEXE}")"

mkdir -p EXEs

nameOfEXE="${nameOfEXE%????}"

nameOfEXE="$(zenity --entry --entry-text="${nameOfEXE}" --text "Type the name of your application")"

if [ ! -d "$HOME/WINEHOMES/${nameOfEXE}" ]; then
	mkdir "$HOME/WINEHOMES/${nameOfEXE}"
fi

if [ ! -d "$HOME/WINEHOMES/${nameOfEXE}/fakehome" ]; then
	mkdir "$HOME/WINEHOMES/${nameOfEXE}/fakehome"
fi

if [ ! -d "$HOME/WINEHOMES/${nameOfEXE}/fakehome/EXE" ]; then
	mkdir "$HOME/WINEHOMES/${nameOfEXE}/fakehome/EXE"
fi

if [ ! -d "$HOME/WINEHOMES/${nameOfEXE}/fakehome/.dosbox" ]; then
	if [ -d "$HOME/WINEHOMES/${WINE_SKELETON}/fakehome/.dosbox" ]; then
		cp -a "$HOME/WINEHOMES/${WINE_SKELETON}/fakehome/.dosbox" "$HOME/WINEHOMES/${nameOfEXE}/fakehome/.dosbox"
	else
		mkdir -p "$HOME/WINEHOMES/${nameOfEXE}/fakehome/.dosbox"
	fi
fi

if [ ! -d "$HOME/WINEHOMES/${nameOfEXE}/fakehome/.cache/wine" ]; then
	if [ -d "$HOME/WINEHOMES/WINE_SKELETON/fakehome/.cache/wine" ]; then
		mkdir -p "$HOME/WINEHOMES/${nameOfEXE}/fakehome/.cache"
		cp -a  "$HOME/WINEHOMES/WINE_SKELETON/fakehome/.cache/wine" "$HOME/WINEHOMES/${nameOfEXE}/fakehome/.cache/wine"
	else
		mkdir -p "$HOME/WINEHOMES/${nameOfEXE}/fakehome/.cache/wine"
	fi
fi

#echo "${pathToEXE}" >> $HOME/WINEHOMES/${nameOfEXE}/disks.txt

exeindex=1

if [ ! -d "$HOME/WINEHOMES/${nameOfEXE}/fakehome/EXE/${exeindex}" ]; then
	mkdir "$HOME/WINEHOMES/${nameOfEXE}/fakehome/EXE/${exeindex}"
fi

ln "${pathToEXE}" "$HOME/WINEHOMES/${nameOfEXE}/fakehome/EXE/${exeindex}/"

pathToEXE="$HOME/WINEHOMES/${nameOfEXE}/fakehome/EXE/${exeindex}"

yesno=0
while true; do
	zenity --question --title "Alert" --text "Would you like to add another CD for this application"
	if [ "$?" = "0" ]; then
		#read path to exe
		#echo "${pathToEXE}" >> $HOME/WINEHOMES/${nameOfEXE}/disks.txt

		while true; do
		pathToEXE="$(zenity --title="Select an EXE file" --file-selection)"
		#echo ${pathToEXE} | rev | cut -c 1-4
			if [ "$(echo ${pathToEXE} | rev | cut -c 1-4 )" != "exe." ] && [ "$(echo ${pathToEXE} | rev | cut -c 1-4 )" != "EXE." ]; then
				zenity --error --title "Error" --text "Please select an EXE file"
			else
				break;
			fi
		done

		exeindex="$(expr ${exeindex} + 1)"

		if [ ! -d "$HOME/WINEHOMES/${nameOfEXE}/EXE/${exeindex}" ]; then
			mkdir "$HOME/WINEHOMES/${nameOfEXE}/fakehome/EXE/${exeindex}"
		fi

		ln "${pathToEXE}" "$HOME/WINEHOMES/${nameOfEXE}/fakehome/EXE/${exeindex}/"
	else
		break;
	fi
done
 
##write run shell script

if [ "${dosOrWine}" = "DOS" ]; then

	cp -a dos-install-exe.sh "$HOME/WINEHOMES/${nameOfEXE}/install.sh"
	chmod +x "$HOME/WINEHOMES/${nameOfEXE}/install.sh"

	cp -a dos-run-exe.sh "$HOME/WINEHOMES/${nameOfEXE}/run.sh"
	chmod +x "$HOME/WINEHOMES/${nameOfEXE}/run.sh"
elif [ "${dosOrWine}" = "Wine" ]; then

	cp -a wine-install-exe.sh "$HOME/WINEHOMES/${nameOfEXE}/install.sh"
	chmod +x "$HOME/WINEHOMES/${nameOfEXE}/install.sh"

	cp -a wine-run-exe.sh "$HOME/WINEHOMES/${nameOfEXE}/run.sh"
	chmod +x "$HOME/WINEHOMES/${nameOfEXE}/run.sh"
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
	sed -i 's#usesandwine="true"#usesandwine="false"#g' "$HOME/WINEHOMES/${nameOfEXE}/install.sh"
fi

if [ "$usesandwine" = "false" ]; then
	sed -i 's#usesandwine="true"#usesandwine="false"#g' "$HOME/WINEHOMES/${nameOfEXE}/run.sh"
fi
# }

#change the installer and runner not to use networking if usesandwine is set to false from install_a_cd (this) script {
if [ "$usenetworking" = "false" ]; then
	sed -i 's#usenetworking="true"#usenetworking="false"#g' "$HOME/WINEHOMES/${nameOfEXE}/install.sh"
fi

if [ "$usenetworking" = "false" ]; then
	sed -i 's#usenetworking="true"#usenetworking="false"#g' "$HOME/WINEHOMES/${nameOfEXE}/run.sh"
fi
# }


cp -a load_secondary_cd.sh "$HOME/WINEHOMES/${nameOfEXE}/"
chmod +x "$HOME/WINEHOMES/${nameOfEXE}/load_secondary_cd.sh"

cp -a config_wine.sh "$HOME/WINEHOMES/${nameOfEXE}/"
chmod +x "$HOME/WINEHOMES/${nameOfEXE}/config_wine.sh"

#yesno=0
#yesno="$(zenity --question --title "Alert" --text "Would you like to try and run autorun.exe?")"
#if [ "$yesno" = "1" ]; then
#
#	cd "$HOME/WINEHOMES/${nameOfEXE}"
#	./run.sh
#fi

umask "${OLD_UMASK}"
