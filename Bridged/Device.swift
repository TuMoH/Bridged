//
//  Device.swift
//  Bridged
//
//  Created by Timur Gasymov on 22.05.17.
//  Copyright © 2017 Timur Gasymov. All rights reserved.
//

import Cocoa
import AVFoundation

struct Device {
    
    let adbId : String
    var model : String?           // Nexus 6
    var name : String?              // Shamu
    var manufacturer : String?      // Motorola
    var brand: String?              //  google
    var serial: String?
    var currentActivity : String = ""

    init(adbId: String, properties: [String:String]) {
        self.adbId = adbId
        model = properties["ro.product.model"]
        name = properties["ro.product.name"]
        manufacturer = properties["ro.product.manufacturer"]
        brand = properties["ro.product.brand"]
    }
    
    func takeScreenshot() {
        print("Cheese...")
        
        let app = (NSApplication.shared().delegate as! AppDelegate)
        
        DispatchQueue.main.async {
            app.startAnimatingIcon()
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy_HHmmss"
        let time = formatter.string(from: date)
        let fileName = "\(manufacturer!)_\(model!)_\(time).png"
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
        print("FileName = \(fileName)")
        let folder = getScreenshotsFolder()
 
        let s = ShellHandler(scriptFile: "screenshot")
        s.outputIsVerbose = true
        let output = s.run(arguments: [adbId, folder, fileName, String(openScreenshot())])
        
        let success = output?.range(of: "do not exist") == nil
        DispatchQueue.main.async {
            let msg = success ? "Success" : "Error"
            app.showNotification(msg, text: success ? "\(folder)/\(fileName)" : (output ?? "Unknown error"))
            app.stopAnimatingIcon()
        }
    }
    
    func openFileManager(_ sender: Any) {
        let fileManager = FileManager(windowNibName: "FileManager")
        fileManager.showWindow(sender)
    }
    
    func getScreenshotsFolder() -> String {
        return UserDefaults.standard.string(forKey: C.PREF_SCREENSHOTS_FOLDER)!
    }
    
    func openScreenshot() -> Bool {
        return UserDefaults.standard.bool(forKey: C.PREF_OPEN_SCREENSHOT)
    }


}
