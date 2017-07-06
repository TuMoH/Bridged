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
    
    func install() -> Bool {
        print("Installing...")
        
        let app = (NSApplication.shared().delegate as! AppDelegate)
        
        DispatchQueue.main.async {
            app.startAnimatingIcon()
        }
        
        let s = ShellHandler(scriptFile: "install")
        s.outputIsVerbose = true
        let output = s.run(arguments: [device.adbId, filepath])
        
        DispatchQueue.main.async {
            let msg = output?.range(of: "Success") != nil ? "Success" : "Error"
            app.showNotification(msg, text: output ?? "Unknown error")
            app.stopAnimatingIcon()
        }
        
        if launchInstalledApp() {
            let apk = getInfoFromApk()
            self.launch(apk: apk)
        }
        
        return output == "Success\n"
    }
    
    func uninstallPackageWithName(_ packageName:String) {
        print("Uninstalling app")
        let s = ShellHandler(scriptFile: "uninstallPackageOnDevice")
        let args = [device.adbId, packageName]
        
        _ = s.run(arguments: args)
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
            _ = s.run(arguments: [device.adbId, ac])
            print("apk done launching")
            print("Running \(apk.appName)")
        }
    }
    
    func launchInstalledApp() -> Bool {
        return UserDefaults.standard.bool(forKey: C.PREF_LAUNCH_INSTALLED_APP)
    }
    
}
