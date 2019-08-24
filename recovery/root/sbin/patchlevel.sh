#!/sbin/sh

syspath="/dev/block/bootdevice/by-name/system"
	
mkdir /s
mount -o ro "$syspath" /s

osver=$(grep -i 'ro.build.version.release' /s/build.prop  | cut -f2 -d'=')
patchlevel=$(grep -i 'ro.build.version.security_patch' /s/build.prop  | cut -f2 -d'=')
sed -i "s/ro.build.version.release=.*/ro.build.version.release="$osver"/g" /default.prop ;
magisk resetprop ro.build.version.security_patch "$patchlevel"
sed -i "s/ro.build.version.security_patch=.*/ro.build.version.security_patch="$patchlevel"/g" /default.prop ;

umount /s
rmdir /s
setprop crypto.ready 1
exit 0
