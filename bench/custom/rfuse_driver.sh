#!/bin/bash

# RFUSE

set -euo pipefail

storage=$1
scrtype=$2
NUM_CORE=("0" "0-1" "0-3" "0-7" "0-15" "0-31")
#NUM_CORE=("0" "0-1")
#NUM_CORE=("none")

interrupt_handler() {
	if [ ${storage} == ramdisk ]; then 
		set +euo pipefail
		sudo rm -rf /mnt/ramdisk/* /mnt/test/*
		sudo umount /mnt/ramdisk /mnt/test
		sudo rm -r /mnt/*

		sudo sync
		set -euo pipefail
	elif [ ${storage} == ssd ]; then 
		set +euo pipefail
		sudo rm -rf /mnt/RFUSE_EXT4/* /mnt/test/*
		sudo umount /mnt/RFUSE_EXT4 /mnt/test
		sudo rm -r /mnt/*

		sudo sync
	else
		echo "Wrong"
	sleep 60
	fi
	
}
trap 'interrupt_handler' SIGINT


for numcore in "${NUM_CORE[@]}"
do
	echo "${numcore}"
	echo 3 > /proc/sys/vm/drop_caches

	if [ ${storage} == ramdisk ]; then
		sudo mkdir -p /mnt/ramdisk /mnt/test
		sudo mount -t tmpfs -o size=15G tmpfs /mnt/ramdisk
		pushd ../../filesystems/stackfs
		make clean
		make
		./StackFS_ll -r /mnt/ramdisk /mnt/test &
		popd

		sudo sync

	elif [ ${storage} == ssd ]; then
		set +euo pipefail
		sudo mkdir -p /mnt/RFUSE_EXT4 /mnt/test

		echo "Mount ext4..."
		sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0 /dev/nvme2n1
		sudo mount /dev/nvme2n1 /mnt/RFUSE_EXT4

		echo "Mount rfuse-stackfs..."
		pushd ../../filesystems/stackfs
		make clean
		make
		./StackFS_ll -r /mnt/RFUSE_EXT4 /mnt/test &
		popd

		sudo sync
	else
		echo "Wrong filesystem"
		exit 0
	fi

	sleep 60

	#mkdir -p logs/rfuse/${storage}/${scrtype}

	echo 3 > /proc/sys/vm/drop_caches

	sleep 10
	
	#[YS] cgroup fio
	sudo ./rfuse_cgroupset.sh  ${numcore} ${storage} ${scrtype}
	#[YS] cgroup fio

	#[YS] On RFUSE for search write action.
	while true;
	do
		sleep 60
	done
	#[YS] On RFUSE for search write action.
	
	#[YS] none cgroup fio
	#fio script/4KB-rand-write-${scrtype}.fio | tee logs/rfuse/${storage}/${scrtype}/rfuse_write_${storage}_${numcore}.log
	#[YS] none cgroup fio

	if [ ${storage} == ramdisk ]; then 
		set +euo pipefail
		sudo rm -rf /mnt/ramdisk/* /mnt/test/*
		sudo umount /mnt/ramdisk /mnt/test
		sudo rm -r /mnt/*

		sudo sync
		set -euo pipefail
	elif [ ${storage} == ssd ]; then 
		set +euo pipefail
		sudo rm -rf /mnt/RFUSE_EXT4/* /mnt/test/*
		sudo umount /mnt/RFUSE_EXT4 /mnt/test
		sudo rm -r /mnt/*

		sudo sync
	else
		echo "Wrong"
	fi
	sleep 60
done
