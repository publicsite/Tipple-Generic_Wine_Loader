#!/bin/sh

cd "$(dirname ${0})"

winedir="$(find . -type d -name ".wine*")"

numofbits=""

if [ "$(echo "${winedir}" | rev | cut -c 1-2)" = "23" ]; then
	numofbits="32"
else
	numofbits="64"
fi

export WINEPREFIX="${HOME}/$(echo "${winedir}" | cut -c 3-)"
export WINEARCH="win${numofbits}"

firejail --private="${PWD}" winecfg