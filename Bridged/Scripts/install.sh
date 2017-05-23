#!/bin/sh

#  installApkOnDevice.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 4/24/15.
#  Copyright (c) 2015 Morten Just Petersen. All rights reserved.


adb=$1 # $1 is the bundle resources path directly from the calling script file
serial=$3
apkPath=$4

"$adb" -s $serial install -r "$apkPath"
