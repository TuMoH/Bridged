//
//  ApkHandler.swift
//  Shellpad
//
//  Created by Morten Just Petersen on 11/1/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class ApkHandler: NSObject {
    
    var filepath:String!
    var device:Device!
    
    init(filepath:String, device:Device){
        print(">>apk init apkhandler")
        super.init()
        self.filepath = filepath
        self.device = device
    }
    
    func installAndLaunch(complete:@escaping ()->Void) {
        let apk = getInfoFromApk()
        if self.install() {
            self.launch(apk: apk)
        }
    }
    
    func install() -> Bool {
        print("Installing...")
        
        let s = ShellHandler(scriptFile: "installApkOnDevice")
        
        s.run(arguments: [device.adbId, filepath])
        print("Installed")
        
        return true
    }
    
    func uninstallPackageWithName(_ packageName:String) {
        print("Uninstalling app")
        let s = ShellHandler(scriptFile: "uninstallPackageOnDevice")
        let args = [device.adbId, packageName]
        
        s.run(arguments: args)
    }
    
    func getInfoFromApk() -> Apk {
        print("Getting info...")
        
        let shell = ShellHandler(scriptFile: "getApkInfo")
        let output = shell.run(arguments: [self.filepath])
        let apk = Apk(rawAaptBadgingData: output!)
        apk.localIconPath = getIcon()
        return apk
    }
    
    func getIcon() -> String? {
        let iconShell = ShellHandler(scriptFile: "extractIconFromApk")
        let output = iconShell.run(arguments: [self.filepath])
        print("Ready to add nsurl path to apk object: \(output)")
        return output?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }


    func launch(apk:Apk) {
        print("Launching...")
        
        if let packageName = apk.packageName, let launcherActivity = apk.launcherActivity {
            
            let ac = "\(packageName)/\(launcherActivity)"
            
            print("apklaunch of \(ac)")
            
            let s = ShellHandler(scriptFile: "launchActivity")
            let output = s.run(arguments: [device.adbId, ac])
            print("apk done launching")
            print("Running \(apk.appName)")
        }
    }
}
