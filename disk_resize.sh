#!/usr/bin/env bash

# workaround for disk resize
sleep 10
sudo lvextend /dev/rootvg/root /dev/vda3 #extend virtual group
sleep 5
sudo resize2fs /dev/rootvg/root #resize file system
