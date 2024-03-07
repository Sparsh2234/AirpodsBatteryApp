//
//  ViewController.swift
//  AirpodsBatteryApp
//
//  Created by Sparsh Pai on 2024-03-05.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {
    var centralManager: CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("HERE")

        // Initialize CBCentralManager
        centralManager = CBCentralManager(delegate: self, queue: nil)
        print(centralManager)
    }

    // MARK: - CBCentralManagerDelegate methods

    func centralManagerDidUpdateState( _ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Start scanning for Bluetooth peripherals
            print("Start scanning")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            // Handle other states
            print("central.state != .poweredOn")
        }
    }

    func centralManager( central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("hi")
        // Process discovered peripherals, including AirPods
        if let name = peripheral.name {
            print("Discovered peripheral: (name)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to peripheral: \(peripheral.name ?? "Unknown")")
        print("Error: \(error?.localizedDescription ?? "Unknown error")")
    }
}

