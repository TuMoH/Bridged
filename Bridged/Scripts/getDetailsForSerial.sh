#!/bin/bash

adb=$1 #Xcode
serial=$3

declare -a arr

GetDetails(){
    "$adb" -s $serial shell getprop
}

GetDetails
