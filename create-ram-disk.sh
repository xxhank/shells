#!/bin/bash
RAMDISK="XCode Boost"
SIZE=4096 #size in MB for ramdisk.
diskutil erasevolume HFS+ "$RAMDISK" $(hdiutil attach -nomount ram://$((SIZE*2048)))
mdutil -i on "/Volumes/$RAMDISK"