#/bin/bash

export PATH=tools/mke2fs/bin:$PATH
export LD_LIBRARY_PATH=tools/mke2fs/lib:$LD_LIBRARY_PATH
export MKE2FS_CONFIG=tools/mke2fs/etc/mke2fs.conf

ROOTFS_DIR=rootfs
ROOTFS_EXT4=rootfs.ext4
#ROOTFS_SIZE=512M
ROOTFS_SIZE=3584M

sudo rm -f $ROOTFS_EXT4
sudo mke2fs -d $ROOTFS_DIR -r 1 -N 0 -m 0 -L "" -O ^64bit $ROOTFS_EXT4 $ROOTFS_SIZE
