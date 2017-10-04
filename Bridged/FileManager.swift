//
//  FileManager.swift
//  Bridged
//
//  Created by Timur Gasymov on 12.09.17.
//  Copyright © 2017 Timur Gasymov. All rights reserved.
//

import Cocoa
import WebKit

class FileManager: NSWindowController, WKScriptMessageHandler {
    
    let DIR = "Scripts"
    
    var webView: WKWebView!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let contentController = WKUserContentController();
        contentController.add(
            self,
            name: "callbackHandler"
        )
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        webView = WKWebView(frame: .zero, configuration: config)
        window?.contentView = webView

        let urlpath = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "html");
        webView.load(URLRequest(url: URL(fileURLWithPath: urlpath!)))
        
        let adbUrl = NSURL(fileURLWithPath: Bundle.main.path(forResource: "adb", ofType: "", inDirectory: DIR)!)
        let adb = getUserAdbPath() ?? adbUrl.path
        
        let cwdString = "window.cwd=\"" + (ProcessInfo.processInfo.arguments[0] as String) + "\""
        webView.evaluateJavaScript(cwdString, completionHandler: nil)
        webView.evaluateJavaScript("window.adb=\"" + adb! + "\"", completionHandler: nil)
    
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
    }
    
    func userContentController(_ userContentController: WKUserContentController,didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            let data = message.body as! NSDictionary
            
            var string = getStringFromCommand(data["command"] as! String, arguments: data["arguments"] as! [String])
            string = string.replacingOccurrences(of: "\n", with: "\\n", options: .literal, range: nil)
            string = string.replacingOccurrences(of: "\r", with: "\\r", options: .literal, range: nil)
            let callbackString = "window.callbacksFromOS[\"" + (data["callbackFunction"] as! String) + "\"](\"" + string + "\")"
            webView?.evaluateJavaScript(callbackString, completionHandler: nil)
        }
    }
    
    func getStringFromCommand(_ command: String, arguments: [String]) -> String {
        let task = Process()
        task.launchPath = command
        task.arguments = arguments
                
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        return output
    }
    
    func getUserAdbPath() -> String? {
        return UserDefaults.standard.string(forKey: C.PREF_ADB_PATH)
    }
    
}
