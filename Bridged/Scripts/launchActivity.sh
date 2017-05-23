#!/bin/sh

#  launchActivity.sh
#  Shellpad
#
#  Created by Morten Just Petersen on 11/1/15.
#  Copyright © 2015 Morten Just Petersen. All rights reserved.
# am start -n yourpackagename/.activityname
# adb shell am start com.mortenjust.streamvsd/com.mortenjust.streamvsd.GridActivity

adb=$1
serial=$3
packageAndActivity=$4

echo "$adb" -s $serial shell am start $packageAndActivity
"$adb" -s $serial shell am start $packageAndActivity
