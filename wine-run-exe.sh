#!/usr/bin/sh

getlnkpath(){
lnkinfo "$1" | grep "^.\s*Local path.*$" | cut -d ':' -f 2- | cut -d ' ' -f 2-
}

getlnkworkingdir(){
lnkinfo "$1" | grep "^.\s*Working directory.*$" | cut -d ':' -f 2- | cut -d ' ' -f 2-
}

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

if [ -d ".wine32" ]; then
	winedir="./.wine32"
elif [ -d ".wine64" ]; then
	winedir="./.wine64"
fi

numofbits=""

if [ "$(echo "${winedir}" | rev | cut -c 1-2)" = "23" ]; then
	numofbits="32"
else
	numofbits="64"
fi

export WINEPREFIX="${thepwd}/.wine${numofbits}"

#if [ ! -d "${thepwd}/.wine" ] && [ ! -L "${thepwd}.wine" ]; then
#ln -s ".wine${numofbits}" ".wine"
#fi

if [ -d "${winedir}/drive_c/ProgramData/Microsoft/Windows/Start Menu" ]; then
#echo WOO
	listOfLNKs="$(find "${winedir}/drive_c/ProgramData/Microsoft/Windows/Start Menu" -type f -name "*.lnk")"

	if [ "$listOfLNKs" = "" ]; then
		listOfLNKs="$(find "${winedir}/drive_c/users/$(whoami)/AppData/Roaming" -type f -name "*.lnk")"
	fi

	if [ "$listOfLNKs" = "" ]; then
		listOfLNKs="$(find "${winedir}/drive_c/users/$(whoami)/Desktop" -type f -name "*.lnk")"
	fi

	if [ "$listOfLNKs" != "" ]; then
#echo WOO2
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
		#echo "eval zenity --list --radiolist --column \"Selection\" --column \"lnk\" ${checked} ${baseLNKs}"
		selection="$(eval zenity --list --radiolist --column \"Selection\" --column \"lnk\" ${baseLNKs})"

	else
		selection=""
#echo WOO5
	fi

	if [ "$selection" != "" ]; then

		#todo: add sandwine
		#thepath="$(firejail --profile=wine --private="${PWD}" winepath --windows "$selection" | grep -o "ProgramData.*")" #work around for broken /unix argument to wine start
		thepath="$(WINEPREFIX="${thepwd}/.wine${numofbits}" winepath --windows "$selection" | grep -o "ProgramData.*")" #work around for broken /unix argument to wine start

		if [ "${thepath}" = "" ]; then
#echo WOO3
			if [ "$usesandwine" = "true" ]; then
				if [ "$(oldwhich wine32)" != "" ]; then
					thepath="$(WINEPREFIX="${thepwd}/.wine${numofbits}" WINEARCH="win${numofbits}" winepath --windows "$selection" | grep -o "users.*")" #work around for broken /unix argument to wine start
					#echo
					#echo "WOOO1 $thepath"
					#echo
				else
					thepath="$(WINEPREFIX="${thepwd}/.wine${numofbits}" winepath /unix --windows "$selection" | grep -o "users.*")" #work around for broken /unix argument to wine start
					#echo
					#echo "WOOO2 $thepath"
					#echo "WOOO2 $selection"
					#echo
				fi
			else
				thepath="$(winepath --windows "$selection" | grep -o "users.*")" #work around for broken /unix argument to wine start
			fi
		fi

		thepath="C:\\${thepath}"
	fi
		#echo "$thepath<<<"
		sleep 2

		#todo: add sandwine
		#firejail --private="${PWD}" wine start "$thepath"
		if [ "$usesandwine" = "true" ]; then
			#echo "HUH ${numofbits}"

			if [ "$selection" != "" ]; then
				selection="$(realpath "${selection}")"

				#echo ${selection}
				workingdir="$(WINEPREFIX="${thepwd}/.wine${numofbits}" winepath --unix "$(getlnkworkingdir "${selection}")" 2>/dev/null)"
				if [ "$workingdir" != "" ]; then
					if [ -d "$workingdir" ]; then
					cd "$workingdir"
					fi
				else
					workingdir="$(WINEPREFIX="${thepwd}/.wine${numofbits}" winepath --unix "$(dirname "${selection}")" 2>/dev/null)"
					if [ -d "$workingdir" ]; then
						cd "$workingdir"
					fi	
				fi


				hmmselection="$(getlnkpath "${selection}")"
				if [ hmmselection != "" ]; then
					selection="${hmmselection}"
				fi
			fi

			#echo "${workingdir}    ${PWD}<<<<"

			if [ "$(oldwhich wine32)" != "" ]; then
				if [ "$selection" = "" ]; then
#echo WOO1352523
					WINEPREFIX="${thepwd}/.wine${numofbits}" WINEARCH="win${numofbits}" HOME="${thepwd}" sandwine --network --pulseaudio --x11 --dotwine "${thepwd}/.wine${numofbits}:rw" --pass "${thepwd}/.dosbox:ro" --pass "${thepwd}/.cache/wine:rw" --pass "${thepwd}/EXE:ro" --pass "${thepwd}:rw" -- 'C:\\'
				else
#echo WOO1352523
					WINEPREFIX="${thepwd}/.wine${numofbits}" WINEARCH="win${numofbits}" HOME="${thepwd}" sandwine --network --pulseaudio --x11 --dotwine "${thepwd}/.wine${numofbits}:rw" --pass "${thepwd}/.dosbox:ro" --pass "${thepwd}/.cache/wine:rw" --pass "${thepwd}/EXE:ro" --pass "${thepwd}:rw" -- "${selection}"
				fi
				#WINEPREFIX="${thepwd}/.wine${numofbits}" WINEARCH="win${numofbits}" sandwine --network --pulseaudio --x11 --dotwine "${thepwd}/.wine${numofbits}:rw" --pass "${thepwd}/.dosbox:ro" --pass "${thepwd}/.cache:rw" --pass "${thepwd}/EXE:ro" --pass "${thepwd}:rw" -- "${selection}"
			else
				if [ "$selection" = "" ]; then
#echo WOO1352523
					WINEPREFIX="${thepwd}/.wine${numofbits}" HOME="${thepwd}" sandwine --network --pulseaudio --x11 --dotwine "${thepwd}/.wine${numofbits}:rw" --pass "${thepwd}/.dosbox:ro" --pass "${thepwd}/.cache/wine:rw" --pass "${thepwd}/EXE:ro" --pass "${thepwd}:rw" -- 'C:\\'
				else
#echo WOO1352523
					WINEPREFIX="${thepwd}/.wine${numofbits}" HOME="${thepwd}" sandwine --network --pulseaudio --x11 --dotwine "${thepwd}/.wine${numofbits}:rw" --pass "${thepwd}/.dosbox:ro" --pass "${thepwd}/.cache/wine:rw" --pass "${thepwd}/EXE:ro" --pass "${thepwd}:rw" -- "${selection}"
				fi
				#WINEPREFIX="${thepwd}/.wine${numofbits}" HOME="${thepwd}" sandwine --network --pulseaudio --x11 --dotwine "${thepwd}/.wine${numofbits}:rw" --pass "${thepwd}/.dosbox:ro" --pass "${thepwd}/.cache:rw" --pass "${thepwd}/EXE:ro" --pass "${thepwd}:rw" start "$thepath"
			fi
		else
			if [ "$(oldwhich wine32)" != "" ]; then
				if [ "$selection" = "" ]; then
#echo PPPPP
#file "${thepwd}/.wine${numofbits}"
					WINEPREFIX="${thepwd}/.wine${numofbits}" WINEARCH="win${numofbits}" wine 'C:\\'
				else
#echo WOO1352523
					WINEPREFIX="${thepwd}/.wine${numofbits}" WINEARCH="win${numofbits}" wine "$thepath"
				fi
			else
				if [ "$selection" = "" ]; then
#echo PPPPP
#file "${thepwd}/.wine${numofbits}"
					WINEPREFIX="${thepwd}/.wine${numofbits}" wine 'C:\\'
				else
#echo WOO1352523
					WINEPREFIX="${thepwd}/.wine${numofbits}" wine "$thepath"
				fi
			fi
		fi
	else
		WINEPREFIX="${thepwd}/.wine${numofbits}" wine start "C:\\"
	fi

sleep 5

while [ "$(ps aux | grep [w]ineserver)" != "" ]; do
sleep 5
done

umask "${OLD_UMASK}"
