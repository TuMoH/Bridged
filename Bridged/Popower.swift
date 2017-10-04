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
    var takeScreenshot = false
    var openFileManager = false
    
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
        
        if takeScreenshot {
            getApp().closePopover(nil)
            
            DispatchQueue.global().async {
                self.devices[row].takeScreenshot()
            }
        }
        
        if openFileManager {
            getApp().closePopover(nil)
            
            self.devices[row].openFileManager(tableView)
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
        if let view = titleView {
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                context.duration = 0.2
                view.animator().alphaValue = 0
            }, completionHandler: { () -> Void in
                view.stringValue = (self.apkForInstall != nil || self.takeScreenshot || self.openFileManager) ? "Choose device..." : "Devices"
                
                NSAnimationContext.runAnimationGroup({ (context) -> Void in
                    context.duration = 0.2
                    view.animator().alphaValue = 1
                }, completionHandler: nil)
            })
        }
    }
    
    @IBAction func openSettings(_ sender: Any) {
        getApp().openSettings(sender)
    }
    
    @IBAction func takeScreenshot(_ sender: Any) {
        if devices.count == 1 {
            getApp().closePopover(nil)
            
            DispatchQueue.global().async {
                _ = self.devices[0].takeScreenshot()
            }
        } else {
        	takeScreenshot = true
        	updateTitle()
        }
    }
    
    @IBAction func openFileManager(_ sender: Any) {
        if devices.count == 1 {
            getApp().closePopover(nil)
            
            self.devices[0].openFileManager(sender)
        } else {
            takeScreenshot = true
            updateTitle()
        }
    }
    
    func reset() {
        autoRefresh = false
        apkForInstall = nil
        takeScreenshot = false
        openFileManager = false
    }
    
    func getApp() -> AppDelegate {
        return (NSApplication.shared().delegate as! AppDelegate)
    }
    
}
