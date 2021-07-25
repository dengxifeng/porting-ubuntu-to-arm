#!/bin/bash

echo "Mounting file system"

sudo mount -t proc	/proc	 rootfs/proc
sudo mount -t sysfs	/sys	 rootfs/sys
sudo mount -o bind	/dev	 rootfs/dev
sudo mount -o bind	/dev/pts rootfs/dev/pts

echo "Change root"

sudo cp /usr/bin/qemu-arm-static rootfs/usr/bin
sudo chroot rootfs
