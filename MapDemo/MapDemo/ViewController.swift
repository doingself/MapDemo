//
//  ViewController.swift
//  MapDemo
//
//  Created by 623971951 on 2018/1/18.
//  Copyright © 2018年 syc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var tabView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "map and location"
        self.view.backgroundColor = UIColor.white
        
        tabView = UITableView(frame: self.view.bounds, style: UITableViewStyle.plain)
        tabView.dataSource = self
        tabView.delegate = self
        self.view.addSubview(tabView)
        
        tabView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension ViewController: UITableViewDataSource{
    // MARK: table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .gray
        cell.accessoryType = .disclosureIndicator
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "core location 定位"
        }else if indexPath.row == 1{
            cell.textLabel?.text = "map kit 大头针 截图 POI"
        }else if indexPath.row == 2{
            cell.textLabel?.text = "map kit 导航 跳转系统地图"
        }else if indexPath.row == 3{
            cell.textLabel?.text = "map kit 导航 2"
        }else{
            cell.textLabel?.text = "cell \(indexPath.row)"
        }
        
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
extension ViewController: UITableViewDelegate{
    // MARK: table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        var v: UIViewController!
        if indexPath.row == 0{
            v = LocaDemoViewController()
        }else if indexPath.row == 1{
            v = MapDemoViewController()
        }else if indexPath.row == 2{
            v = MapGuideDemoViewController()
        }else if indexPath.row == 3{
            v = MapGuideDemo2ViewController()
        }
        
        if v != nil{
            self.navigationController?.pushViewController(v!, animated: true)
        }
    }
}
