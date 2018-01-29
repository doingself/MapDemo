//
//  MapDemoViewController.swift
//  MapDemo
//
//  Created by 623971951 on 2018/1/29.
//  Copyright © 2018年 syc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapDemoViewController: UIViewController {

    private var mapView: MKMapView!
    private var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "map kit 大头针 截图 POI"
        self.view.backgroundColor = UIColor.white
        
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        mapView = MKMapView(frame: self.view.bounds)
        self.view.addSubview(mapView)
        
        //为MKMapView设置delegate
        mapView.delegate = self
        
        // 显示用户当前位置 1 showsUserLocation = true
        //是否显示用户当前位置 ios8之后才有，默认为false
        // 在地图上显示一个蓝点,代表用户的位置,地图不会缩放, 而且当用户位置移动时, 地图不会跟随用户位置移动而移动
        mapView.showsUserLocation = true
        
        // 显示用户当前位置 2 FollowWithHeading
        //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
        //Follow   跟踪并在地图上显示用户的当前位置
        //FollowWithHeading  跟踪并在地图上显示用户的当前位置，地图会跟随用户的前进方向进行旋转
        mapView.userTrackingMode = .follow
        
        //地图的显示风格，此处设置使用标准地图
        //MKMapType.standard ：标准地图
        //MKMapType.satellite ：卫星地图
        //MKMapType.hybrid ：混合地图
        mapView.mapType = .standard
        
        //地图是否可滚动，默认为true
        mapView.isScrollEnabled = true
        //地图是否缩放，默认为true
        mapView.isZoomEnabled = true
        // 是否旋转
        mapView.isRotateEnabled = true
        // 是否显示3D view
        mapView.isPitchEnabled = true
        
        if #available(iOS 9.0, *) {
            // 显示指南针
            mapView.showsCompass = true
            // 显示比例
            mapView.showsScale = true
            // 显示交通
            mapView.showsTraffic = true
        }
        // 显示建筑
        mapView.showsBuildings = true
        // 显示兴趣
        mapView.showsPointsOfInterest = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1. 获取当前触摸点所在的位置
        guard let point = touches.first?.location(in: mapView) else { return }
        
        // 2. 把触摸点所在的位置, 转换成为在地图上的经纬度坐标
        let coordinate: CLLocationCoordinate2D = mapView.convert(point, toCoordinateFrom: mapView)
        
        print("touch \(coordinate)")
        
        // TODO: 添加大头针
        
        // 创建3D视图的对象
        // 参数1: 需要看的位置的中心点   参数2: 从哪个地方看   参数3: 站多高看（眼睛的海拔，单位：米）
        let camera: MKMapCamera = MKMapCamera(
            lookingAtCenter: coordinate,
            fromEyeCoordinate: CLLocationCoordinate2D(
                latitude: coordinate.latitude + 0.001,
                longitude: coordinate.longitude + 0.001
            ),
            eyeAltitude: 1)
        mapView.setCamera(camera, animated: true)
        
        // 截图
        let option: MKMapSnapshotOptions = MKMapSnapshotOptions()
        option.mapRect = mapView.visibleMapRect  // 设置地图区域
        option.region = mapView.region       // 设置截图区域(在地图上的区域,作用在地图)
        option.mapType = .standard           // 截图的地图类型
        option.showsPointsOfInterest = true  // 是否显示POI
        option.showsBuildings = true         // 是否显示建筑物
        // option.size = CGSize(width: 100, height: 100)// 设置截图后的图片大小(作用在输出图像)
        option.size = self.mapView.frame.size    // 设置截图后的图片大小(作用在输出图像)
        option.scale = UIScreen.main.scale       // 设置截图后的图片比例（默认是屏幕比例， 作用在输出图像）
        // 截图对象
        let snapShoter = MKMapSnapshotter(options: option)
        snapShoter.start { (shot: MKMapSnapshot?, error: Error?) in
            if error != nil {
                print("map snap shotter start error = \(error!)")
                return
            }
            // 得到截图
            guard let img = shot?.image else { return }
            // TODO: 保存到相册
            //UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        }
        
        
        // POI
        // 1. 创建一个POI请求
        let request: MKLocalSearchRequest = MKLocalSearchRequest()
        // 2.1 设置请求检索的关键字
        request.naturalLanguageQuery = "银行"
        // 2.2 设置请求检索的区域范围
        request.region = mapView.region
        
        let search: MKLocalSearch = MKLocalSearch(request: request)
        search.start { (response: MKLocalSearchResponse?, error: Error?) in
            if error != nil{
                print("local search start error = \(error!)")
                return
            }
            guard let items = response?.mapItems else {return}
            for item: MKMapItem in items{
                print("local search start item = \(String(describing: item.name))")
            }
        }
    }
    
    func requestLocationAccess() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            break
            
        case .denied, .restricted:
            print("location access denied")
            
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }

}
extension MapDemoViewController: MKMapViewDelegate{
    // MARK: map delegate
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("地图的显示区域即将发生改变的时候调用")
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("地图的显示区域已经发生改变的时候调用")
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        print("开始加载地图")
    }
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("地图加载结束")
    }
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("地图加载失败 \(error)")
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        print("开始渲染地图")
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        print("渲染地图结束")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //MKUserLocation: 遵守了MKAnnotation协议，封装地图上大头针的位置信息（位置信息CLLocation、标题title、子标题subtitle）
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        if annotationView == nil {
            //MKAnnotationView：可以用指定的图片作为大头针的样式，但显示的时候没有动画效果，如果没有给图片的话会什么都不显示,使用MKAnnotationView子类MKPinAnnotationView创建系统样式大头针
            //MKPinAnnotationView:系统自带的大头针视图，继承与MKAnnotationView。
            annotationView =  MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            //显示子标题和标题
            annotationView!.canShowCallout = true
            //设置大头针描述的偏移量
            annotationView!.calloutOffset = CGPoint(x:0, y: -10)
            //设置大头针描述左边的控件
            annotationView!.leftCalloutAccessoryView = UIButton(type: .contactAdd)
            //设置大头针描述右边的控件
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            // 设置大头针下落动画
            annotationView?.animatesDrop = true
            // 可以拖拽
            annotationView?.isDraggable = true
            if #available(iOS 9.0, *) {
                annotationView?.pinTintColor = UIColor.green
            } else {
                annotationView?.pinColor = MKPinAnnotationColor.purple
            }
        }else{
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("添加 annotation 注释视图")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        print("点击注释视图按钮")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("点击大头针注释视图")
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("取消点击大头针注释视图")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationViewDragState,
                 fromOldState oldState: MKAnnotationViewDragState) {
        print("移动annotation位置时调用")
    }
    
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        print("正在跟踪用户的位置")
    }
    
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        print("停止跟踪用户的位置")
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("更新用户的位置 \(userLocation.coordinate)")
        
        let coorinate2D = userLocation.coordinate
        
        //创建MKPointAnnotation对象——代表一个大头针
        let pointAnnotation = MKPointAnnotation()
        //设置大头针的经纬度
        pointAnnotation.coordinate = coorinate2D
        pointAnnotation.title = "title"
        pointAnnotation.subtitle = "sub title"
        //添加大头针
        self.mapView.addAnnotation(pointAnnotation)
        
        
        //设置地图显示的范围，地图显示范围越小，细节越清楚
        let span = MKCoordinateSpan(latitudeDelta:0.005, longitudeDelta:0.005)
        //创建MKCoordinateRegion对象，该对象代表了地图的显示中心和显示范围。
        let region = MKCoordinateRegion(center: coorinate2D, span: span)
        //设置当前地图的显示中心和显示范围
        self.mapView.setRegion(region, animated:true)
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        print("跟踪用户的位置失败")
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode,
                 animated: Bool) {
        print("改变UserTrackingMode")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay)
        -> MKOverlayRenderer {
            print("设置overlay的渲染")
            return MKPolylineRenderer()
    }
    
    private func mapView(mapView: MKMapView,
                         didAddOverlayRenderers renderers: [MKOverlayRenderer]) {
        print("地图上加了overlayRenderers后调用")
    }
}
