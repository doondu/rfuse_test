#!/bin/bash

#SSD RFUSE

set -euo pipefail

storage=$1
scrtype=$2
NUM_CORE=("0" "0-1" "0-3" "0-7" "0-15" "0-31")

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


for numcore in "${NUM_CORE}[@]"
do

	echo 3 > /proc/sys/vm/drop_caches

	if [ ${storage} == ramdisk ]; then
		sudo mount -t tmpfs -o size=50G tmpfs /mnt/ramdisk
		pushd ../../filesystems/stackfs
		make clean
		make
		./StackFS_ll -r /mnt/ramdisk /mnt/test &
		popd

		sudo sync

	elif [ ${storage} == ssd ]; then
		set +euo pipefail
		echo "Unmount rfuse-stackfs..."
		sudo umount /mnt/RFUSE_EXT4
	
		echo "Unmount ext4..."
		sudo umount /mnt/test
		set -euo pipefail

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

	mkdir -p logs/rfuse/${storage}/${scrtype}

	echo 3 > /proc/sys/vm/drop_caches

	sleep 10

	cgclear
	mount -t cgroup2 none /sys/fs/cgroup
	echo "+cpuset" > /sys/fs/cgroup/cgroup.subtree_control
	mkdir /sys/fs/cgroup/mygroup
	echo "+cpuset" > /sys/fs/cgroup/mygroup/cgroup.subtree_control
	echo "${numcore}" > /sys/fs/cgroup/mygroup/cpuset.cpus
	cat /sys/fs/cgroup/mygroup/cpuset.cpus
	echo "$PPID" > /sys/fs/cgroup/mygroup/cgroup.procs

	fio script/4KB-rand-write-${scrtype}.fio | tee logs/rfuse/${storage}/${scrtype}/rfuse_write_${storage}_${numcore}.log

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
done
