//
//  Preferences.swift
//  Bridged
//
//  Created by Timur Gasymov on 29.06.17.
//  Copyright © 2017 Timur Gasymov. All rights reserved.
//

import Cocoa

class Preferences: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func selectAdbPath(_ sender: Any) {
        selectFolder(title: "ADB", message: "Choose adb", defaultsPath: C.PREF_ADB_PATH)
    }
    
    func selectFolder(title:String, message:String, defaultsPath:String){
        let openPanel = NSOpenPanel();
        openPanel.title = title
//        openPanel.message = message
        openPanel.showsResizeIndicator=true;
        openPanel.canChooseDirectories = false;
        openPanel.canChooseFiles = true;
        openPanel.allowsMultipleSelection = false;
        openPanel.canCreateDirectories = true;
        openPanel.begin { (result) -> Void in
            if(result == NSFileHandlingPanelOKButton){
                let path = openPanel.url!.path
                print("selected adb is \(path), saving to \(defaultsPath)");
                let ud = UserDefaults.standard
                ud.setValue(path, forKey: defaultsPath)
            }
        }
    }
    
}
