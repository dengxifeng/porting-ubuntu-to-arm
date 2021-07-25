#!/bin/bash

echo "Umounting file system"

sudo umount rootfs/proc
sudo umount rootfs/sys
sudo umount rootfs/dev/pts
sudo umount rootfs/dev

sudo rm rootfs/usr/bin/qemu-arm-static
sudo rm rootfs/root/.bash_history
