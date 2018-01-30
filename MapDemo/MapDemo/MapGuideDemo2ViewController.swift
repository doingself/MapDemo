//
//  MapGuideDemo2ViewController.swift
//  MapDemo
//
//  Created by 623971951 on 2018/1/29.
//  Copyright © 2018年 syc. All rights reserved.
//

import UIKit
import MapKit

class MapGuideDemo2ViewController: UIViewController {
    
    private var mapView: MKMapView!
    private lazy var geoCoder: CLGeocoder = {
        return CLGeocoder()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "map kit 导航 touch"
        self.view.backgroundColor = UIColor.white
        
        mapView = MKMapView(frame: self.view.bounds)
        self.view.addSubview(mapView)
        
        mapView.delegate = self
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        geoCoder.geocodeAddressString("北京") { (pls: [CLPlacemark]?, error) -> Void in
            // 1. 拿到北京地标对象
            let gzPL = pls?.first
            // 1.2 创建圆形的覆盖层数据模型
            let circle1 = MKCircle(center: (gzPL?.location?.coordinate)!, radius: 100000)
            // 1.3 添加覆盖层数据模型到地图上
            self.mapView.add(circle1)
            
            self.geoCoder.geocodeAddressString("上海") { (pls: [CLPlacemark]?, error) -> Void in
                // 2. 拿到上海地标对象
                let shPL = pls?.first
                // 2.2 创建圆形的覆盖层数据模型
                let circle2 = MKCircle(center: (shPL?.location?.coordinate)!, radius: 100000)
                // 2.3 添加覆盖层数据模型到地图上
                self.mapView.add(circle2)
                
                // 3 大头针
                let annotation: MKPointAnnotation = MKPointAnnotation()
                annotation.title = "上海"
                annotation.coordinate = (pls?.first?.location?.coordinate)!
                self.mapView.addAnnotation(annotation)
                //self.mapView.showAnnotations([annotation], animated: true)
                
                
                //45. 调用获取导航线路数据信息的方法
                self.getRouteMessage(gzPL!, endCLPL: shPL!)
            }
        }
    }
    // MARK: - ① 根据两个地标，发送网络请求给苹果服务器获取导航数据，请求对应的行走路线信息
    func getRouteMessage(_ startCLPL: CLPlacemark, endCLPL: CLPlacemark) {
        
        // 创建请求导航路线数据信息
        let request: MKDirectionsRequest = MKDirectionsRequest()
        
        // 创建起点:根据 CLPlacemark 地标对象创建 MKPlacemark 地标对象
        let sourceMKPL: MKPlacemark = MKPlacemark(placemark: startCLPL)
        request.source = MKMapItem(placemark: sourceMKPL)
        
        // 创建终点:根据 CLPlacemark 地标对象创建 MKPlacemark 地标对象
        let endMKPL: MKPlacemark = MKPlacemark(placemark: endCLPL)
        request.destination = MKMapItem(placemark: endMKPL)
        
        request.transportType = .automobile
        
        // 1. 创建导航对象，根据请求，获取实际路线信息
        let directions: MKDirections = MKDirections(request: request)
        
        // 2. 调用方法, 开始发送请求,计算路线信息
        directions.calculate { (response:MKDirectionsResponse?, error:Error?) in
        
            if let err = error {
                print("MKDirections.calculate err = \(err)")
            }
            if let resp = response {
                print(resp)
                
                // MARK: - ② 解析导航数据
                // 遍历 routes （MKRoute对象）：因为有多种路线
                for route: MKRoute in resp.routes {
                    
                    // 添加覆盖层数据模型,路线对应的几何线路模型（由很多点组成）
                    // 当我们添加一个覆盖层数据模型时, 系统绘自动查找对应的代理方法, 找到对应的覆盖层"视图"
                    // 添加折线
                    self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
                    
                    print(route.advisoryNotices)
                    print(route.name, route.distance, route.expectedTravelTime)
                    // 遍历每一种路线的每一个步骤（MKRouteStep对象）
                    for step in route.steps {
                        print(step.instructions) // 打印步骤说明
                    }
                }
            }
        }
    }
}
extension MapGuideDemo2ViewController: MKMapViewDelegate{
    // MARK: map delegate
    // MARK: - ③ 添加导航路线到地图
    // MARK: - 当添加一个覆盖层数据模型到地图上时, 地图会调用这个方法, 查找对应的覆盖层"视图"(渲染图层)
    // 参数1（mapView）：地图    参数2（overlay）：覆盖层"数据模型"   returns: 覆盖层视图
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        var resultRender = MKOverlayRenderer()
        
        // 折线覆盖层
        if overlay is MKPolyline{
            
            // 创建折线渲染对象 (不同的覆盖层数据模型, 对应不同的覆盖层视图来显示)
            let render: MKPolylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            render.lineWidth = 6                // 设置线宽
            render.strokeColor = UIColor.red    // 设置颜色
            
            resultRender = render
            
        }else if overlay is MKCircle {
            // 圆形覆盖层
            let circleRender: MKCircleRenderer = MKCircleRenderer(overlay: overlay)
            
            circleRender.fillColor = UIColor.lightGray // 设置填充颜色
            circleRender.alpha = 0.3               // 设置透明色
            circleRender.strokeColor = UIColor.blue
            circleRender.lineWidth = 2
            
            resultRender = circleRender
        }
        return resultRender
    }
}
