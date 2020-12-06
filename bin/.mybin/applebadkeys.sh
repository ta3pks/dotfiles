#!/bin/bash
lsusb | grep -i "unifying receiver" > /dev/null
test $? -eq 0 && setxkbmap -option apple:badmap
