//
//  MapGuideDemoViewController.swift
//  MapDemo
//
//  Created by 623971951 on 2018/1/29.
//  Copyright © 2018年 syc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapGuideDemoViewController: UIViewController {

    private lazy var geoCoder: CLGeocoder = {
        return CLGeocoder()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "map kit 导航 touch 跳转系统地图"
        self.view.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // MARK: - 地理编码（导航包括:起点和终点  数据由苹果处理）
        geoCoder.geocodeAddressString("北京") { (pls: [CLPlacemark]?, error) -> Void in
            // 1. 拿到北京地标对象
            let gzPL = pls?.first
            
            self.geoCoder.geocodeAddressString("上海") { (pls: [CLPlacemark]?, error) -> Void in
                // 2. 拿到上海地标对象
                let shPL = pls?.first
                
                // 3. 调用开始导航的方法（从北京到上海）
                self.beginNav(gzPL!, endPLCL: shPL!)
            }
        }
    }
    func beginNav(_ startPLCL: CLPlacemark, endPLCL: CLPlacemark) {
        
        /*
        //MKPlacemark(coordinate: CLLocationCoordinate2D, addressDictionary: [String : Any]?)
        // coordinate 2D ---> MKPlacemark ---> MKMapItem
        let toCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 30.0, longitude: 30.0)
        let toMKPlacemark: MKPlacemark = MKPlacemark(coordinate: toCoordinate, addressDictionary: nil)
        let toLocation: MKMapItem = MKMapItem(placemark: toMKPlacemark)
        toLocation.name = "去的地方";
        */
        
        // MKPlacemark(placemark: CLPlacemark)
        // GLGeocoder geocoderAddressString CLPlacemark ---> MKPlacemark ---> MKMapItem
        // 获取起点
        let startplMK: MKPlacemark = MKPlacemark(placemark: startPLCL)
        let startItem: MKMapItem = MKMapItem(placemark: startplMK)
        
        // 获取终点
        let endplMK: MKPlacemark = MKPlacemark(placemark: endPLCL)
        let endItem: MKMapItem = MKMapItem(placemark: endplMK)
        
        // 设置起点和终点
        let mapItems: [MKMapItem] = [startItem, endItem]
        
        // 设置导航地图启动项参数字典
        let dic: [String : AnyObject] = [
            // 导航模式:驾驶
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving as AnyObject,
            // 地图样式：标准样式
            MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue as AnyObject,
            // 显示交通：显示
            MKLaunchOptionsShowsTrafficKey: true as AnyObject
        ]
        
        // 根据 MKMapItem 的起点和终点组成数组, 通过导航地图启动项参数字典, 调用系统的地图APP进行导航
        MKMapItem.openMaps(with: mapItems, launchOptions: dic)
    }
}
extension MapGuideDemoViewController: MKMapViewDelegate{
    // MARK: map delegate
}
