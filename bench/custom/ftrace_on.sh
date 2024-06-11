#!/bin/bash

sudo echo function > /sys/kernel/debug/tracing/current_tracer
#sudo echo "/mnt/test/" > /sys/kernel/debug/tracing/set_graph_filter
sudo echo 1 > /sys/kernel/debug/tracing/tracing_on
#sudo echo "Hello, World!" > /mnt/test/test_file.txt
fio script/4KB-rand-write-libaio.fio
sudo echo 0 > /sys/kernel/debug/tracing/tracing_on
sudo cp /sys/kernel/debug/tracing/trace ./logs/rfuse/ftrace/testing_0604.txt
