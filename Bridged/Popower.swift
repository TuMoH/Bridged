//
//  Popower.swift
//  Bridged
//
//  Created by Timur Gasymov on 23.05.17.
//  Copyright © 2017 Timur Gasymov. All rights reserved.
//

import Cocoa

class Popower: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var deviceTable: NSTableView!
    @IBOutlet weak var titleView: NSTextField!
    
    var devices: [Device] = []
    var apkForInstall: String?
    
    var autoRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceTable.dataSource = self
        deviceTable.delegate = self
        
        updateTitle()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let device = devices[row]
        if (device.manufacturer != nil && device.model != nil) {
            return device.manufacturer! + " " + device.model!
        }
        return "Error"
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if apkForInstall != nil {
            let path = self.apkForInstall!
            
            getApp().closePopover(nil)

            DispatchQueue.global().async {
                let apkHandler = ApkHandler(filepath: path, device: self.devices[row])
                _ = apkHandler.install()
            }
        }
        return true
    }
    
    func updateData(_ devices: [Device]) {
        self.devices = devices
        deviceTable?.reloadData()
        
        if autoRefresh {
            print("autoRefresh")
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(refreshDevices), userInfo: nil, repeats: false)
        }
    }
    
    func refreshDevices() {
        if !autoRefresh {
            return
        }
        getApp().refreshDevices(nil)
    }
    
    func updateTitle() {
        titleView?.stringValue = apkForInstall == nil ? "Devices" : "Choose device..."
    }
    
    @IBAction func openSettings(_ sender: Any) {
        getApp().openSettings(sender)
    }    
    
    func getApp() -> AppDelegate {
        return (NSApplication.shared().delegate as! AppDelegate)
    }
    
}
