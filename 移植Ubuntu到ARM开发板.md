# 准备工作

## 下载Ubuntu base

清华镜像：https://mirror.tuna.tsinghua.edu.cn/ubuntu-cdimage/ubuntu-base/releases/20.04.2

此文下载了[ubuntu-base-20.04.2-base-armhf.tar.gz](https://mirror.tuna.tsinghua.edu.cn/ubuntu-cdimage/ubuntu-base/releases/20.04.2/release/ubuntu-base-20.04.2-base-armhf.tar.gz)

## 安装qemu

```shell
sudo apt install qemu-user-static
```

## 解压Ubuntu base

```shell
mkdir rootfs
sudo tar -zxf /path/to/ubuntu-base-20.04.2-base-armhf.tar.gz -C rootfs
```

## 修改软件源

网络正常情况下，不建议修改。

## 挂载

创建mount.sh文件，和rootfs放在一起，内容如下：

```shell
#!/bin/bash

echo "Mounting file system"

sudo mount -t proc      /proc    rootfs/proc
sudo mount -t sysfs     /sys     rootfs/sys
sudo mount -o bind      /dev     rootfs/dev
sudo mount -o bind      /dev/pts rootfs/dev/pts

echo "Change root"

sudo cp /usr/bin/qemu-arm-static rootfs/usr/bin
sudo chroot rootfs
```

## 卸载

创建umount.sh文件，和rootfs放在一起，内容如下：

```shell
#!/bin/bash

echo "Umounting file system"

sudo umount rootfs/proc
sudo umount rootfs/sys
sudo umount rootfs/dev/pts
sudo umount rootfs/dev

sudo rm rootfs/usr/bin/qemu-arm-static
```

# 安装软件

## 挂载并chroot

```shell
$ ./mount.sh
Mounting file system
Change root
```

## 设置root密码

```shell
passwd root
```

## 设置主机名和host

```shell
echo frontier > /etc/hostname
echo 127.0.0.1 localhost > /etc/hosts
echo 127.0.0.1 frontier > /etc/hosts
```

## 配置DNS

```shell
echo nameserver 8.8.8.8 > /etc/resolv.conf
```

## 安装常用软件

```shell
apt update
apt install -y locales language-pack-en-base
echo LANG=en_US.UTF-8 > /etc/locale.conf
apt install -y systemd systemd-sysv sudo net-tools ethtool ifupdown iputils-ping vim ssh bash-completion parted
```

### 使能命令自动完成

```shell
vi /root/.bashrc
```

uncomment bash_completion.

```shell
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
```

### 允许root登录ssh

```shell
echo PermitRootLogin yes >> /etc/ssh/sshd_config
```

### 启动重新挂载rootfs

```shell
vi /etc/fstab
```

内容：

```shell
# <file system>   <dir>         <type>    <options>                          <dump> <pass>
/dev/mmcblk0p6    /             ext4      defaults,noatime,errors=remount-ro 0      1
```

## 设置串口

调试串口为ttySLB0，需要为其添加一个systemd的服务。这里只需要创建一个getty@ttySLB0.server的链接，链接到getty@.service即可，操作如下：

```shell
ln -s /lib/systemd/system/getty\@.service /etc/systemd/system/getty.target.wants/getty\@ttySLB0.service
```

## 配置网络

```shell
echo auto eth0 > /etc/network/interfaces.d/eth0
echo iface eth0 inet dhcp >> /etc/network/interfaces.d/eth0
```

## 安装桌面

安装lubuntu-desktop：

```shell
apt install lubuntu-desktop
```

### 允许root登录图形界面

需要修改两个文件 `/etc/pam.d/gdm-autologin` `/etc/pam.d/gdm-password`，将其中的
`auth required pam_succeed_if.so user != root quiet_success`
行注释掉即可。

## 卸载

```shell
exit
```

执行umout.sh

```shell
./umount.sh
```

# 制作rootfs镜像

创建gen_rootfs.sh文件，和rootfs放在一起，内容如下：

```shell
#/bin/bash

export PATH=tools/mke2fs/bin:$PATH
export LD_LIBRARY_PATH=tools/mke2fs/lib:$LD_LIBRARY_PATH
export MKE2FS_CONFIG=tools/mke2fs/etc/mke2fs.conf

ROOTFS_DIR=rootfs
ROOTFS_EXT4=rootfs.ext4
ROOTFS_SIZE=3584M

sudo rm -f $ROOTFS_EXT4
sudo mke2fs -d $ROOTFS_DIR -r 1 -N 0 -m 0 -L "" -O ^64bit $ROOTFS_EXT4 $ROOTFS_SIZE
```

制作rootfs镜像：

```shell
./gen_rootfs.sh
```

