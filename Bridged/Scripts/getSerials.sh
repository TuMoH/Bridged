#!/bin/bash

adb=$1
let deviceCount=0

declare -a arr

GetSerials(){
    while read line
    do
        if [ -n "$line" ] && [ "`echo $line | awk '{print $2}'`" == "device" ]
        then
            let deviceCount=$deviceCount+1
            serial="`echo $line | awk '{print $1}'`"

            if (( deviceCount > 1 ))
            then
                serials=$serials";"
            fi

            serials=$serials$serial
        fi
    done < <("$adb" devices)
echo $serials
}

GetSerials
