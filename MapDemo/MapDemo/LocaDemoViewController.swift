//
//  LocaDemoViewController.swift
//  MapDemo
//
//  Created by 623971951 on 2018/1/18.
//  Copyright © 2018年 syc. All rights reserved.
//

import UIKit

class LocaDemoViewController: UIViewController {

    private lazy var locationService: LocationService = {
        return LocationService()
    }()
    
    private var infoLabel: UILabel!
    private var updateInfoLabelTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "location"
        self.view.backgroundColor = UIColor.white
        
        infoLabel = UILabel()
        infoLabel.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
        infoLabel.frame = CGRect(x: 6, y: 200, width: self.view.frame.size.width - 12, height: 14 * 10)
        
        infoLabel.font = UIFont.systemFont(ofSize: 10)
        infoLabel.textAlignment = .left
        infoLabel.textColor = UIColor.white
        infoLabel.numberOfLines = 0
        self.view.addSubview(infoLabel)
        
        updateInfoLabelTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(self.updateInfoLabel),
            userInfo: nil,
            repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationService.startLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationService.stopLocation()
    }
    @objc func updateInfoLabel(){
        guard let location = locationService.currentLocation else { return }
        infoLabel.text = "location = \(location.coordinate)"
    }
}
