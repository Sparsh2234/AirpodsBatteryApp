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
    
    var peripheralMap: [UUID: CBPeripheral] = [:]
    var peripheralList: [CBPeripheral] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        for (uuid, peripheral) in peripheralMap {
//            let labelView = UILabel()
//            labelView.text = peripheral.name
//            stackView.addArrangedSubview(labelView)
//        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        refreshButton.addTarget(self, action: #selector(didClickRefreshButton), for: .touchUpInside)
        
    }
    
    @objc func didClickRefreshButton(_ sender: UIButton) {
        tableView.reloadData()
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
    
    
}
    
