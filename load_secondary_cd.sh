#!/bin/sh

OLD_UMASK="$(umask)"
umask 0022

theCDlist=""
old_IFS="$IFS"
IFS="
"
for line in $(find ISO -type f -name "*.iso" | sort); do
theCDlist="${theCDlist} FALSE \"${line}\""
done
theISO="$(eval zenity --list --radiolist --column "Selection" --column "CD"${theCDlist})"
IFS="$old_IFS"

cdemu unload all
cdemu load 0 "${theISO}"

umask "${OLD_UMASK}"
