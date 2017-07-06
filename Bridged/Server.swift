//
//  Server.swift
//  Bridged
//
//  Created by Timur Gasymov on 29.05.17.
//  Copyright © 2017 Timur Gasymov. All rights reserved.
//

import Foundation
import Swifter

public func createServer() -> HttpServer {
    
    let server = HttpServer()
    
    server["/"] = scopes {
        html {
            body {
                ul(server.routes) { service in
                    li {
                        a { href = service; inner = service }
                    }
                }
            }
        }
    }
    server.POST["/install"] = { r in
        let app = (NSApplication.shared().delegate as! AppDelegate)
        
        let formFields = r.parseUrlencodedForm()
        DispatchQueue.main.async {
            app.popup?.apkForInstall = formFields[0].1
            app.showPopover(nil)
        }
        
        return HttpResponse.ok(.html(""))
    }
    
    server.notFoundHandler = scopes {
        html {
            body {
                center {
                    h1 { inner = "Not found" }
                }
            }
        }
    }

    return server
}
