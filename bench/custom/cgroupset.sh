#!/bin/bash

numcore=$1
storage=$2
scrtype=$3
echo "${numcore}"
sudo cgclear
sudo mount -t cgroup2 none /sys/fs/cgroup
sudo echo "+cpuset" > /sys/fs/cgroup/cgroup.subtree_control
sudo mkdir /sys/fs/cgroup/mygroup
sudo echo "+cpuset" > /sys/fs/cgroup/mygroup/cgroup.subtree_control
sudo echo "${numcore}" > /sys/fs/cgroup/mygroup/cpuset.cpus
sudo cat /sys/fs/cgroup/mygroup/cpuset.cpus
sudo echo $$ > /sys/fs/cgroup/mygroup/cgroup.procs

#stress -c 10

fio script/4KB-rand-write-${scrtype}.fio | tee logs/rfuse/${storage}/${scrtype}1/rfuse_write_${numcore}.log

#YS On ftrace for searching RFUSE's write action
#sudo ./ftrace_on.sh
#YS On ftrace for searching RFUSE's write action

