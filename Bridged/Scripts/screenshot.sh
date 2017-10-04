#!/bin/sh

#  takeScreenshotOfDeviceWithSerial.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 4/23/15.
#  Copyright (c) 2015 Morten Just Petersen. All rights reserved.

#!/bin/bash

declare -a arr

adb=$1 # $1 is the bundle resources path directly from the calling script file
serial=$3
screenshotFolder=$4
fileName=$5
openScreenshot=$6

TakeScreenshot(){
    echo "Taking screenshot of $serial"

    "$adb" -s $serial shell screencap -p /sdcard/$fileName
    "$adb" -s $serial pull /sdcard/$fileName
    "$adb" -s $serial shell rm /sdcard/$fileName

    if [ $openScreenshot = "true" ]; then
        open $fileName
    fi
}

mkdir -p "$screenshotFolder"
cd "$screenshotFolder"
TakeScreenshot
