//
//  ViewController.swift
//  AirpodsBatteryApp
//
//  Created by Sparsh Pai on 2024-03-05.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")

        // Initialize CBCentralManager
        centralManager = CBCentralManager(delegate: self, queue: nil)
//        print(centralManager)
    }

    // MARK: - CBCentralManagerDelegate methods

    func centralManagerDidUpdateState( _ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Start scanning for Bluetooth peripherals
            print("Start scanning: (central.state == .poweredOn)")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            // Handle other states
            print("NOT scanning: (central.state != .poweredOn)")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print("didDiscover")
        // Process discovered peripherals, including AirPods
        if let name = peripheral.name {
            print("Discovered peripheral: \(name): \(peripheral)")
//            print("Advertising: \(name): \(advertisementData)\n")
            
            // Check if the Battery Service UUID is present in the advertisement data
            if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID],
                serviceUUIDs.contains(CBUUID(string: "0000180F-0000-1000-8000-00805F9B34FB")) {

                // Connect to the peripheral to retrieve battery information
                central.connect(peripheral, options: nil)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral.name ?? "Unknown")")

        // Set the peripheral's delegate to self
        peripheral.delegate = self

        // Discover services of the connected peripheral
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to peripheral: \(peripheral.name ?? "Unknown")")
        print("Error: \(error?.localizedDescription ?? "Unknown error")")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral: \(peripheral.name ?? "Unknown")")
    }
    
    // MARK: - CBPeripheralDelegate methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices")
        if let services = peripheral.services {
            for service in services {
                print("Discovered service: \(service.uuid)")
                // Check if the service is the Battery Service
                if service.uuid == CBUUID(string: "0000180F-0000-1000-8000-00805F9B34FB") {
                    // Discover characteristics of the Battery Service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor")
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Discovered characteristic: \(characteristic.uuid)")
                // Check if the characteristic is the Battery Level characteristic
                if characteristic.uuid == CBUUID(string: "00002A19-0000-1000-8000-00805F9B34FB") {
                    // Read the value of the Battery Level characteristic
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor")
        if characteristic.uuid == CBUUID(string: "00002A19-0000-1000-8000-00805F9B34FB") {
            // Handle the battery level value
            if let value = characteristic.value {
                let batteryLevel = value[0]
                print("Battery Level: \(batteryLevel)%")
            }
        }
    }
}

