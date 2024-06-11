#!/bin/bash

sudo ./fuse_driver.sh ramdisk origin
sudo ./fuse_driver.sh ramdisk libaio
sudo ./fuse_driver.sh ramdisk fsync
