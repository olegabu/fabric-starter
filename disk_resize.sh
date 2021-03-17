#!/usr/bin/env bash

# workaround for disk resize
sleep 1
sudo lvextend /dev/ubuntu-vg/ubuntu-lv /dev/sda3 #extend virtual group
sleep 5
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv #resize file system
