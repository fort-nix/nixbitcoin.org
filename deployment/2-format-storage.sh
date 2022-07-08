#!/usr/bin/env bash
set -euxo pipefail

disk1=/dev/sda
disk2=/dev/sdb
bootSize=512MiB
# `swapSize` should equal system RAM.
# This setup will create one swap partition on each disk.
swapSize=${swapSize:-32GiB}

# Remount already formatted storage
mountStorage() {
    if ! zfs get type rpool &>/dev/null; then
        zpool import -f -N rpool
    fi
    mount -t zfs -o x-mount.mkdir rpool/root /mnt
    mount -t zfs -o x-mount.mkdir rpool/nix /mnt/nix
    mount -o x-mount.mkdir ${disk1}2 /mnt/boot1
    mount -o x-mount.mkdir ${disk2}2 /mnt/boot2
}

if [[ ${1:-} == remount ]]; then
    mountStorage
    exit
fi

formatDisk() {
  disk=$1
  sgdisk --zap-all \
   -n 0:0:+1MiB      -t 0:ef02 -c 0:bios-boot \
   -n 0:0:+$bootSize -t 0:8300 -c 0:boot \
   -n 0:0:+$swapSize -t 0:8200 -c 0:swap \
   -n 0:0:0          -t 0:bf01 -c 0:root $disk
}
formatDisk $disk1
formatDisk $disk2
mkfs.fat -n boot1 ${disk1}2
mkfs.fat -n boot2 ${disk2}2
mkswap -L swap1 ${disk1}3
mkswap -L swap2 ${disk2}3

# ashift=12
# Set pool sector size to 2^12 to optimize performance for storage devices with 4K sectors.
# Auto-detection of physical sector size (/sys/block/sdX/queue/physical_block_size) can be unreliable.
#
# acltype=posixacl
# Required for / and the systemd journal
#
# xattr=sa
# Improve performance of certain extended attributes
#
# normalization=formD
# Enable UTF-8 normalization for file names
#
zpool create -f \
  -o ashift=12 \
  -O acltype=posixacl \
  -O xattr=sa \
  -O normalization=formD \
  -O relatime=on \
  -O compression=lz4 \
  -O dnodesize=auto \
  rpool mirror ${disk1}4 ${disk2}4

zfs create -o mountpoint=legacy rpool/root
zfs create -o mountpoint=legacy rpool/nix
zfs create -o mountpoint=none -o refreservation=1G rpool/reserved
zfs set com.sun:auto-snapshot=true rpool/root

mountStorage
