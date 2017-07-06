//
//  AppDelegate.swift
//  Bridged
//
//  Created by Timur Gasymov on 22.05.17.
//  Copyright © 2017 Timur Gasymov. All rights reserved.
//

import Cocoa
import Swifter

//import Swifter

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    var devices = [Device]()

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    let popover = NSPopover()
    var popup: Popower?
    var eventMonitor: EventMonitor?
    
    @IBOutlet weak var menu: NSMenu!
    
    var preferences: Preferences!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        createPopup()
        NSUserNotificationCenter.default.delegate = self
        
//        startServer()
    }
    
    func startServer() {
        let server = createServer()
        do {
            try server.start(8783)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        createPopup()
        
        refreshDevices { 
            if (self.devices.count == 1) {
                DispatchQueue.global().async {
                    let apkHandler = ApkHandler(filepath: filename, device: self.devices[0])
                    _ = apkHandler.install()
                }
            } else {
                self.popup?.apkForInstall = filename
                self.showPopover(sender)
            }
        }
        
        return true
    }
    
    func showNotification(_ title: String, text: String) {
        let notification = NSUserNotification()
        
        notification.title = title
        notification.informativeText = text
        
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    private func createPopup() {
        setDefaultStatusIcon()
        
        if let button = statusItem.button {
            button.action = #selector(statusBarButtonClicked)
            button.sendAction(on: [NSEventMask.leftMouseUp, NSEventMask.rightMouseUp])
        }
        
        popup = Popower(nibName: "Popower", bundle: nil)
        popover.contentViewController = popup
        
        eventMonitor = EventMonitor(mask: [NSEventMask.leftMouseDown, NSEventMask.rightMouseDown]) { [unowned self] event in
            self.closePopover(event)
        }
    }
    
    private func setDefaultStatusIcon() {
        let icon = NSImage(named: "StatusIcon")
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
    }
    
    func showPopover(_ sender: Any?) {
        if !popover.isShown {
            if let button = statusItem.button {
                popup?.updateTitle()
                
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                eventMonitor?.start()
                
                popup?.autoRefresh = true
                refreshDevices(nil)
            }
        }
    }
    
    func closePopover(_ sender: Any?) {
        if popover.isShown {
            popover.performClose(sender)
            eventMonitor?.stop()
            
            popup?.autoRefresh = false
            popup?.apkForInstall = nil
        }
    }
    
    func statusBarButtonClicked(_ sender: Any?) {
        let event = NSApp.currentEvent!
        if event.type == NSEventType.rightMouseUp {
            menu.popUp(positioning: menu.item(at: 0), at: NSEvent.mouseLocation(), in: nil)
        } else {
            togglePopover(sender)
        }
    }
    
    func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func refreshDevices(_ complete: (() -> Void)?) {
        DispatchQueue.global().async {
            self.devices = DeviceHandler.getDevices()
            
            DispatchQueue.main.async {
                self.popup?.updateData(self.devices)
                complete?()
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    @IBAction func quit(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func openSettings(_ sender: Any) {
        closePopover(sender)
        
        preferences = Preferences(windowNibName: "Preferences")
        preferences.showWindow(sender)
    }
    
    
    var animReverse = false
    var animTimer: Timer? = nil
    var animFrame = 0
    
    func startAnimatingIcon() {
        animFrame = 0
        updateImageIcon()
        animTimer = Timer.scheduledTimer(timeInterval: 1/10, target: self, selector: #selector(updateImageIcon), userInfo: nil, repeats: true)
    }
    
    func stopAnimatingIcon() {
        setDefaultStatusIcon()
        animTimer?.invalidate()
        animTimer = nil
    }
    
    func updateImageIcon() {
        let icon = NSImage(named: "StatusIconAnim")?.imageRotatedByDegreess(degrees: CGFloat(animFrame * 8))
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        
        if animReverse {
            animFrame -= 1
        } else {
            animFrame += 1
        }
        
        if animFrame >= 1 {
            animReverse = true
        }
        if animFrame <= -1 {
            animReverse = false
        }
    }
    
}

