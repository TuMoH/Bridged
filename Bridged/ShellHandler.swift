//
//  Shellprocesser.swift
//  Bridged
//
//  Created by Timur Gasymov on 22.05.17.
//  Copyright © 2017 Timur Gasymov. All rights reserved.
//

import Cocoa

class ShellHandler: NSObject {
    
    let DIR = "Scripts"
    
    var scriptFile:String!
    var process:Process!
    var outputIsVerbose = false;
    
    init(scriptFile:String) {
        self.scriptFile = scriptFile
        print("Run : \(scriptFile)")
    }
    
    func stop() {
        process.terminate()
    }
    
    func run(arguments args:[String]=[]) -> String? {
        if scriptFile == nil {
            return nil
        }
        
        let scriptPath = Bundle.main.path(forResource: scriptFile, ofType: "sh", inDirectory: DIR)
        let resourcesUrl = NSURL(fileURLWithPath: Bundle.main.path(forResource: "adb", ofType: "", inDirectory: DIR)!).deletingLastPathComponent
        let resourcesPath = resourcesUrl?.path
        let adb = "/Users/androidtim/Library/Android/sdk/platform-tools/adb"
        
        let bash = "/bin/bash"
        
        process = Process()
        let pipe = Pipe()
        
        process.launchPath = bash
        
        var allArguments = [String]()
        allArguments.append(scriptPath!) // $0
        allArguments.append(adb) // $1
        allArguments.append(resourcesPath!) // $2

        for arg in args {
            allArguments.append(arg)
        }
        
        process.arguments = allArguments
        process.standardOutput = pipe
        process.standardError = pipe
        
        // post a notification with the command, for the rawoutput debugging window
        if self.outputIsVerbose {
            postNotification(message: scriptPath!, channel: C.NOTIF_COMMANDVERBOSE)
        } else {
            postNotification(message: scriptPath!, channel: C.NOTIF_COMMAND)
        }
        
        self.process.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)!
        
        var channel = ""
        if self.outputIsVerbose {
            channel = C.NOTIF_NEWDATAVERBOSE
        } else {
            channel = C.NOTIF_NEWDATA
        }
        self.postNotification(message: output, channel: channel)
        return output
    }
    
    func postNotification(message:String, channel:String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: channel), object: message)
    }
    
}
