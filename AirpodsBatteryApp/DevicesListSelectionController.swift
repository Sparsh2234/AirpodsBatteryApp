//
//  DevicesListSelectionController.swift
//  AirpodsBatteryApp
//
//  Created by Sparsh Pai on 2024-03-07.
//

import Foundation
import UIKit
import CoreBluetooth

protocol DevicesListSelectionControllerDelegate {
    func didCompleteDeviceSelection(selectedDeviceList: [String])
}

class DevicesListSelectionController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    
    var peripheralMap: [UUID: CBPeripheral] = [:]
    var peripheralList: [CBPeripheral] = []
    var selectedDeviceList: [String] = []
    
    var delegate: DevicesListSelectionControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        refreshButton.addTarget(self, action: #selector(didClickRefreshButton), for: .touchUpInside)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.didCompleteDeviceSelection(selectedDeviceList: selectedDeviceList)
    }
    
    @objc func didClickRefreshButton(_ sender: UIButton) {
        tableView.reloadData()
    }
    
    @IBAction func CloseModal(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension DevicesListSelectionController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text = peripheralList[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        if let textLabel = currentCell.textLabel?.text {
            selectedDeviceList.append(textLabel)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        if let textLabel = currentCell.textLabel?.text {
            if let index = selectedDeviceList.firstIndex(of: textLabel) {
                selectedDeviceList.remove(at: index)
            }
        }
    }
    
    
}
    
