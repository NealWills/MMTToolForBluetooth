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

class ViewController: UIViewController {

    var searchView: SearchView?
    var tableView: UITableView?
    var deviceList: [MMTToolForBleDevice] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchView = SearchView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
        self.view.addSubview(searchView)
        searchView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(44)
            make.height.equalTo(44)
        }
        self.searchView = searchView

        let tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

