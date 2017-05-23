#!/bin/sh

#  getApkInfo.sh
#  Shellpad
#
#  Created by Morten Just Petersen on 11/1/15.
#  Copyright © 2015 Morten Just Petersen. All rights reserved.

echo "get apk info"

thisdir=$2
filename=$3
aapt=$thisdir/aapt

echo "$aapt" dump badging "$filename"

"$aapt" dump badging "$filename"
