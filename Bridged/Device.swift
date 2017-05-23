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

}
