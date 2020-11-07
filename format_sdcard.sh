#!/bin/bash

sgdisk -Z $1

sgdisk -n 1:0:+50M -t 1:c12a7328-f81f-11d2-ba4b-00a0c93ec93b -c 1:"BIOS BOOT Partition" $1
#sgdisk -n 2:0:+10G -t 2:0657fd6d-a4ab-43c4-84e5-0933c84b4f4f -c 2:"Swap"                $1
sgdisk -n 2:0:0    -t 2:4f68bce3-e8cd-4db1-96e7-fbcaf984b709 -c 2:"Root FS"             $1

mkfs -t vfat ${1}p1

#mkfs.btrfs -f ${1}1
#mkfs.btrfs -f ${1}2
