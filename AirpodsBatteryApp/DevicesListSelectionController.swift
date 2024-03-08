//
//  DevicesListSelectionController.swift
//  AirpodsBatteryApp
//
//  Created by Sparsh Pai on 2024-03-07.
//

import Foundation
import UIKit
import CoreBluetooth

class DevicesListSelectionController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    var peripheralMap: [UUID: CBPeripheral] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for (uuid, peripheral) in peripheralMap {
            let labelView = UILabel()
            labelView.text = peripheral.name
            stackView.addArrangedSubview(labelView)
        }
    }
}
    
