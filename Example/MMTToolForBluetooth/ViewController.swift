//
//  ViewController.swift
//  MMTToolForBluetooth
//
//  Created by NealWills on 01/26/2025.
//  Copyright (c) 2025 NealWills. All rights reserved.
//

import UIKit
import MMTToolForBluetooth
import SnapKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    var searchView: SearchView?
    var tableView: UITableView?
    var deviceList: [MMTToolForBleDevice] = []
    
    var disposeBag: DisposeBag = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchView = SearchView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
        self.view.addSubview(searchView)
        searchView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(44)
            make.height.equalTo(60)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        searchView.content = "ME_Box"
        searchView.searchAction = { [weak self] content in
            self?.searchAction(content)
        }
        self.searchView = searchView

        let tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        tableView.register(BleDeviceCell.self, forCellReuseIdentifier: "BleDeviceCell")
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
        
        _ = MMTTimer.addTimer(repeatDistance: .seconds(1), disposeBag: self.disposeBag) { [weak self] currentT, timer in
            if currentT < 2 { return }
            timer.destroyUnit()
            self?.searchAction(searchView.content)
        }
        
        MMTToolForBleManager.shared.addDelegate(self)
    
    }
    
    func searchAction(_ content: String?) {
        MMTToolForBleManager.shared.startScan(perfix: content)
    }
    
    func deviceConnect(_ indexPath: IndexPath) {
        if deviceList.count <= indexPath.row { return }
        let device = deviceList[indexPath.row]
        if device.connectStatus == .scan {
            MMTToolForBleManager.connect(device: device)
        } else if device.connectStatus == .connected {
            MMTToolForBleManager.disconnect(device: device)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: MMTToolForBleManagerDelegate {
    
    func mmtBleManagerDidDiscoverDevice(_ device: MMTToolForBleDevice?) {
        let deviceList = MMTToolForBleManager.shared.deviceList.map({
            return $0.value
        }).sorted(by: {
            if $0.connectStatus.weightValue == $1.connectStatus.weightValue {
                return ($0.rssi ?? -300) > ($1.rssi ?? -300)
            }
            return $0.connectStatus.weightValue > $1.connectStatus.weightValue
        })
        self.deviceList.removeAll()
        self.deviceList.append(contentsOf: deviceList)
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    func mmtBleManagerDeviceConnectStatusDidChange(_ device: MMTToolForBleDevice?, status: MMTToolForBleDevice.ConnectStatus) {
        let deviceList = MMTToolForBleManager.shared.deviceList.map({
            return $0.value
        }).sorted(by: {
            if $0.connectStatus.weightValue == $1.connectStatus.weightValue {
                return ($0.rssi ?? -300) > ($1.rssi ?? -300)
            }
            return $0.connectStatus.weightValue > $1.connectStatus.weightValue
        })
        self.deviceList.removeAll()
        self.deviceList.append(contentsOf: deviceList)
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    func mmtBleManagerDeviceRssiDidChange(_ device: MMTToolForBleDevice?, rssi: Int?) {
        let deviceList = MMTToolForBleManager.shared.deviceList.map({
            return $0.value
        }).sorted(by: {
            if $0.connectStatus.weightValue == $1.connectStatus.weightValue {
                return ($0.rssi ?? -300) > ($1.rssi ?? -300)
            }
            return $0.connectStatus.weightValue > $1.connectStatus.weightValue
        })
        self.deviceList.removeAll()
        self.deviceList.append(contentsOf: deviceList)
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    func mmtBleManagerDeviceNameDidChange(_ device: MMTToolForBleDevice?, origin: String?, new: String?) {
        let deviceList = MMTToolForBleManager.shared.deviceList.map({
            return $0.value
        }).sorted(by: {
            if $0.connectStatus.weightValue == $1.connectStatus.weightValue {
                return ($0.rssi ?? -300) > ($1.rssi ?? -300)
            }
            return $0.connectStatus.weightValue > $1.connectStatus.weightValue
        })
        self.deviceList.removeAll()
        self.deviceList.append(contentsOf: deviceList)
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    func mmtBleManagerDeviceServerDidDiscover(_ device: MMTToolForBleDevice?, service: MMTService?, character: MMTCharacteristic?) {
        let deviceList = MMTToolForBleManager.shared.deviceList.map({
            return $0.value
        }).sorted(by: {
            if $0.connectStatus.weightValue == $1.connectStatus.weightValue {
                return ($0.rssi ?? -300) > ($1.rssi ?? -300)
            }
            return $0.connectStatus.weightValue > $1.connectStatus.weightValue
        })
        self.deviceList.removeAll()
        self.deviceList.append(contentsOf: deviceList)
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    func mmtBleManagerDeviceServerDidUpdate(_ device: MMTToolForBleDevice?, service: MMTService?, character: MMTCharacteristic?, value: Data?) {
        let deviceList = MMTToolForBleManager.shared.deviceList.map({
            return $0.value
        }).sorted(by: {
            if $0.connectStatus.weightValue == $1.connectStatus.weightValue {
                return ($0.rssi ?? -300) > ($1.rssi ?? -300)
            }
            return $0.connectStatus.weightValue > $1.connectStatus.weightValue
        })
        self.deviceList.removeAll()
        self.deviceList.append(contentsOf: deviceList)
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    func mmtBleManagerDeviceServerDidWrite(_ device: MMTToolForBleDevice?, service: MMTService?, character: MMTCharacteristic?, value: Data?) {
        let deviceList = MMTToolForBleManager.shared.deviceList.map({
            return $0.value
        }).sorted(by: {
            if $0.connectStatus.weightValue == $1.connectStatus.weightValue {
                return ($0.rssi ?? -300) > ($1.rssi ?? -300)
            }
            return $0.connectStatus.weightValue > $1.connectStatus.weightValue
        })
        self.deviceList.removeAll()
        self.deviceList.append(contentsOf: deviceList)
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    
    func mmtBleManagerDeviceRssiDidChange(_ device: MMTToolForBleDevice?) {
        let deviceList = MMTToolForBleManager.shared.deviceList.map({
            return $0.value
        }).sorted(by: {
            if $0.connectStatus.weightValue == $1.connectStatus.weightValue {
                return ($0.rssi ?? -300) > ($1.rssi ?? -300)
            }
            return $0.connectStatus.weightValue > $1.connectStatus.weightValue
        })
        self.deviceList.removeAll()
        self.deviceList.append(contentsOf: deviceList)
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.deviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BleDeviceCell") as? BleDeviceCell else {
            return UITableViewCell()
        }
        if self.deviceList.count <= indexPath.row { return cell }
        cell.device = deviceList[indexPath.row]
        cell.connectAction = { [weak self] in
            self?.deviceConnect(indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.deviceList.count <= indexPath.row { return 0.0000001 }
        return BleDeviceCell.cellHeightFor(deviceList[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

