//
//  ViewController.swift
//  AirpodsBatteryApp
//
//  Created by Sparsh Pai on 2024-03-05.
//

import UIKit
import ExternalAccessory

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        let connectedAccessories = EAAccessoryManager.shared().connectedAccessories
        let supportedProtocols = ["yourProtocol1", "yourProtocol2"]
        let filteredAccessories = connectedAccessories.filter { accessory in
            return (accessory.protocolStrings.first).map { supportedProtocols.contains($0) } ?? false
        }
        
        for accessory in filteredAccessories {
            print(accessory)
        }
    }


}

