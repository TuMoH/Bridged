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
        select(title: "ADB", message: "Choose adb", defaultsPath: C.PREF_ADB_PATH, folder: false, file: true)
    }
    
    @IBAction func selectScreenshotsFolder(_ sender: Any) {
        select(title: "Screenshots", message: "Choose screenshots folder", defaultsPath: C.PREF_SCREENSHOTS_FOLDER, folder: true, file: false)
    }
    
    func select(title:String, message:String, defaultsPath:String, folder: Bool, file: Bool) {
        let openPanel = NSOpenPanel();
        openPanel.title = title
        //        openPanel.message = message
        openPanel.showsResizeIndicator=true;
        openPanel.canChooseDirectories = folder;
        openPanel.canChooseFiles = file;
        openPanel.allowsMultipleSelection = false;
        openPanel.canCreateDirectories = true;
        openPanel.begin { (result) -> Void in
            if(result == NSFileHandlingPanelOKButton){
                let path = openPanel.url!.path
                print("selected \(title) is \(path), saving to \(defaultsPath)");
                let ud = UserDefaults.standard
                ud.setValue(path, forKey: defaultsPath)
            }
        }
    }
    
    
    
}
