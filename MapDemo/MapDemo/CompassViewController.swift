//
//  CompassViewController.swift
//  MapDemo
//
//  Created by 623971951 on 2018/2/6.
//  Copyright © 2018年 syc. All rights reserved.
//

import UIKit
import CoreLocation

class CompassViewController: UIViewController {
    
    private lazy var locationService: LocationService = {
        let locationService = LocationService()
        locationService.delegate = self
        return locationService
    }()
    
    private var infoLabel: UILabel!
    private var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "compass"
        self.view.backgroundColor = UIColor.white
        
        imgView = UIImageView(frame: self.view.bounds)
        imgView.contentMode = UIViewContentMode.scaleAspectFit
        self.view.addSubview(imgView)
        
        let img = UIImage(named: "compass.jpg")
        imgView.image = img
        
        let line = UIView(frame: CGRect(x: self.view.frame.size.width/2-1, y: 0, width: 2, height: self.view.frame.size.height/2))
        line.backgroundColor = UIColor.red
        self.view.addSubview(line)
        self.view.bringSubview(toFront: line)
        
        infoLabel = UILabel()
        infoLabel.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
        infoLabel.frame = CGRect(x: 6, y: 200, width: self.view.frame.size.width - 12, height: 14 * 10)
        
        infoLabel.font = UIFont.systemFont(ofSize: 10)
        infoLabel.textAlignment = .left
        infoLabel.textColor = UIColor.white
        infoLabel.numberOfLines = 0
        self.view.addSubview(infoLabel)
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
}
extension CompassViewController: LocationServiceDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        //// 磁极方向（磁北对应于随时间变化的地球磁场极点）
        //newHeading.magneticHeading
        //// 真实方向（真北始终指向地理北极点）
        //newHeading.trueHeading
        ////方向的精度
        //newHeading.headingAccuracy
        ////时间
        //newHeading.timestamp
        
        // 弧度 ＝ 度 × π / 180
        // 度 ＝ 弧度 × 180° / π
        // 180度 ＝ π弧度
        
        // 90°＝ 90 × π / 180 ＝ π/2 弧度
        // 60°＝ 60 × π / 180 ＝ π/3 弧度
        
        let angle = newHeading.magneticHeading//拿到当前设备朝向 0- 359.9 角度
        let arc = CGFloat(angle / 180 * Double.pi)//角度转换成为弧度
        UIView.animate(withDuration: 0.5, animations: {
            self.imgView.transform = CGAffineTransform(rotationAngle: -arc)
        })
        
        infoLabel.text = "朝向 \(newHeading.magneticHeading)\n"
        infoLabel.text?.append("真实 \(newHeading.trueHeading)\n")
        infoLabel.text?.append("精度 \(newHeading.headingAccuracy)\n")
    }
}
