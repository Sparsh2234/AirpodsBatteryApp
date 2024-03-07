//
//  ViewController.swift
//  AirpodsBatteryApp
//
//  Created by Sparsh Pai on 2024-03-05.
//

import UIKit
import ExternalAccessory

class ViewController: UIViewController, EAAccessoryDelegate {
    
    override func viewDidLoad() {
        let connectedAccessories = EAAccessoryManager.shared().connectedAccessories
        let supportedProtocols = ["com.apple.mfi-battery", "com.apple.mfi-serial", "org.bluetooth.service.battery_service"]
        let filteredAccessories = connectedAccessories.filter { accessory in
            return (accessory.protocolStrings.first).map { supportedProtocols.contains($0) } ?? false
        }
        
        for accessory in filteredAccessories {
            print(accessory)
        }
    }
    
    func accessoryDidDisconnect(_ accessory: EAAccessory) {
        //
    }


}

