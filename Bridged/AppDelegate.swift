//
//  AppDelegate.swift
//  Bridged
//
//  Created by Timur Gasymov on 22.05.17.
//  Copyright © 2017 Timur Gasymov. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var devices = [Device]()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DispatchQueue.global().async {
            self.devices = DeviceHandler.getDevices()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    func application(sender: NSApplication, openFile filename: String) -> Bool {
        print("opening \(filename). If it's an APK we'll show a list of devices")
        return true
    }

}

