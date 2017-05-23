#!/bin/sh

#  uninstallPackageOnDevice.sh
#  AndroidTool
#
#  Created by Morten Just Petersen on 12/5/15.
#  Copyright © 2015 Morten Just Petersen. All rights reserved.

adb=$1 # $1 is the bundle resources path directly from the calling script file
serial=$3
packageName=$4


# uninstall -k ..would keep cache and data files
echo "$adb" -s $serial uninstall -r "$packageName"
"$adb" -s $serial uninstall "$packageName"
