//
//  ViewController.swift
//  AirpodsBatteryApp
//
//  Created by Sparsh Pai on 2024-03-05.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, DevicesListSelectionControllerDelegate {
    
    @IBOutlet weak var devicesListStackView: UIStackView!
    @IBOutlet weak var showDeviceSelectionModalButton: UIButton!
    
    
    var centralManager: CBCentralManager!
    var peripheralMap: [UUID: CBPeripheral] = [:]
    var peripheralList: [CBPeripheral] = []
    var addedDeviceSet = Set<String>()
    var devicesSelectionController: DevicesListSelectionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        devicesSelectionController = storyBoard.instantiateViewController(withIdentifier: "devicesSelectionController") as? DevicesListSelectionController
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        showDeviceSelectionModalButton.addTarget(self, action: #selector(presentDeviceSelectionModal), for: .touchUpInside)
    }
    
    // MARK: - Segue Data Passthrough
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if (segue.identifier == "DevicesListSegue") {
    //            self.devicesSelectionController = segue.destination as? DevicesListSelectionController
    //
    //        }
    //    }
    
    @objc func presentDeviceSelectionModal(_ sender: UIButton) {
        devicesSelectionController?.delegate = self
        devicesSelectionController?.peripheralList = self.peripheralList
        devicesSelectionController?.peripheralMap = self.peripheralMap
        if let vc = devicesSelectionController {
            present(vc, animated: true)
        }
    }
    
    // MARK: - DevicesListSelectionController Delegate Method
    
    func didCompleteDeviceSelection(selectedDeviceList: [String]) {
        for deviceName in selectedDeviceList {
            if !addedDeviceSet.contains(deviceName) {
                addedDeviceSet.insert(deviceName)
                
                addedDeviceSet.insert(deviceName)
                
                let containerView = UIView()
                containerView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.2)
                containerView.layer.cornerRadius = 8
                
                let label = UILabel()
                label.text = deviceName
                label.textColor = UIColor.black
                label.font = UIFont.systemFont(ofSize: 16)
                label.textAlignment = .center
                
                // Add label to the container view
                containerView.addSubview(label)
                label.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
                    label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                    label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
                    label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                ])
                
                // Add the container view to the stack view
                devicesListStackView.addArrangedSubview(containerView)
                
                NSLayoutConstraint.activate([
                    containerView.leadingAnchor.constraint(equalTo: devicesListStackView.leadingAnchor, constant: 15),
                    containerView.trailingAnchor.constraint(equalTo: devicesListStackView.trailingAnchor, constant: -15)
                ])
                
                // Apply animation (optional)
                containerView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    containerView.alpha = 1
                }
            }
        }
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
        // Process discovered peripherals, including AirPods
        if let name = peripheral.name {
            print("Discovered peripheral: \(name)")
            peripheralMap[peripheral.identifier] = peripheral
            
            if !peripheralList.contains(peripheral) {
                peripheralList.append(peripheral)
                devicesSelectionController?.peripheralList.append(peripheral)
            }
            
            // Check if the Battery Service UUID is present in the advertisement data
            if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID],
               serviceUUIDs.contains(CBUUID(string: "0000180F-0000-1000-8000-00805F9B34FB")) {
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
        print("didDiscoverServices for \(peripheral.name ?? "Unknown peripheral")")
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
        print("didDiscoverCharacteristicsFor \(service.uuid) on \(peripheral.name ?? "Unknown peripheral")")
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
        print("didUpdateValueFor \(characteristic.uuid) on \(peripheral.name ?? "Unknown peripheral")")
        if characteristic.uuid == CBUUID(string: "00002A19-0000-1000-8000-00805F9B34FB") {
            // Handle the battery level value
            if let value = characteristic.value {
                let batteryLevel = value[0]
                print("Battery Level: \(batteryLevel)%")
            }
        }
    }
}

