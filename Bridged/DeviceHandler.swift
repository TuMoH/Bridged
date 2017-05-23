//
//  DeviceHandler.swift
//  Bridged
//
//  Created by Timur Gasymov on 23.05.17.
//  Copyright © 2017 Timur Gasymov. All rights reserved.
//

import Foundation

class DeviceHandler: NSObject {
    
    static func getDevices() -> [Device] {
        var devices = [Device]()
        
        let serials = getSerials()
        if serials != nil {
            for serial in serials! {
                let properties = self.getDetailsForSerial(serial)
                let device = Device(adbId: serial, properties: properties)
                devices.append(device)
            }
        }
        return devices
    }
    
    private static func getSerials() -> [String]? {
        let task = ShellHandler(scriptFile: "getSerials")
        task.outputIsVerbose = true
        let output = task.run()
        
        if (output?.utf16.count)! < 2 {
            return nil
        }
        
        let serials = output?.characters.split { $0 == ";" }
            .map { String($0).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
        return serials
    }
    
    private static func getDetailsForSerial(_ serial:String) -> [String:String] {
        print("getDetailsForSerial: \(serial)")
        let task = ShellHandler(scriptFile: "getDetailsForSerial")
        task.outputIsVerbose = true
        let output = task.run(arguments: ["\(serial)"])
        let detailsDict = self.getPropsFromString(string: output!)
        return detailsDict
    }
    
    private static func getPropsFromString(string:String) -> [String:String] {
        let re = try! NSRegularExpression(pattern: "\\[(.+?)\\]: \\[(.+?)\\]", options: [])
        let matches = re.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
        
        var propDict = [String:String]()
        
        for match in matches {
            let key = (string as NSString).substring(with: match.rangeAt(1))
            let value = (string as NSString).substring(with: match.rangeAt(2))
            propDict[key] = value
        }
        return propDict
    }
    
}
