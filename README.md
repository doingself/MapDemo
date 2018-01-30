# MapDemo

`CoreLocation` 的功能用户获取地理数据

`MapKit` 的功能是将 `CoreLocation` 获取的数据使用MapKit框架以UI的形式展示出来

+ core location 定位
+ map kit 大头针 截图 POI
+ map kit 导航 touch 跳转系统地图
+ map kit 导航 touch

## CoreLocation

初始化

```
locationManager = CLLocationManager()

//设置定位服务管理器代理
locationManager.delegate = self

/*
 kCLLocationAccuracyBestForNavigation ：精度最高，一般用于导航
 kCLLocationAccuracyBest ： 精确度最佳
 kCLLocationAccuracyNearestTenMeters ：精确度10m以内
 kCLLocationAccuracyHundredMeters ：精确度100m以内
 kCLLocationAccuracyKilometer ：精确度1000m以内
 kCLLocationAccuracyThreeKilometers ：精确度3000m以内
 */
//设置定位进度
locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//定位准确度。distanceFilter表示更新位置的距离，假如超过设定值则进行定位更新，否则不更新。
//kCLDistanceFilterNone表示不设置距离过滤，即随时更新地理位置
locationManager.distanceFilter = kCLDistanceFilterNone
locationManager.headingFilter = kCLHeadingFilterNone
locationManager.pausesLocationUpdatesAutomatically = false

//发送授权申请
locationManager.requestWhenInUseAuthorization()
```


开始定位
```
if (CLLocationManager.locationServicesEnabled())
{
    //允许使用定位服务的话，开启定位服务更新
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
}
```

停止定位
```
locationManager.stopUpdatingLocation()
locationManager.stopUpdatingHeading()
```

代理
```
extension LocationService: CLLocationManagerDelegate{
    // MARK: CL location manager delegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("did update locations \(locations.count) \(locations)")
        
        //获取坐标
        guard let managerLocation:CLLocation = manager.location else{ return }
        //当前位置
        currentLocation = managerLocation
    }
}

```

## MapKit

### 添加 大头针
```
let coorinate2D: CLLocationCoordinate2D = userLocation.coordinate
        
//创建MKPointAnnotation对象——代表一个大头针
let pointAnnotation = MKPointAnnotation()
//设置大头针的经纬度
pointAnnotation.coordinate = coorinate2D
pointAnnotation.title = "title"
pointAnnotation.subtitle = "sub title"
//添加大头针
self.mapView.addAnnotation(pointAnnotation)
```

### 显示 3D 画面
```
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
```

### 截图
```
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
```

### POI 检索
```
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
```


### 使用系统导航

coordinate 2D ---> MKPlacemark ---> MKMapItem

```
//MKPlacemark(coordinate: CLLocationCoordinate2D, addressDictionary: [String : Any]?)
// coordinate 2D ---> MKPlacemark ---> MKMapItem
let toCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 30.0, longitude: 30.0)
let toMKPlacemark: MKPlacemark = MKPlacemark(coordinate: toCoordinate, addressDictionary: nil)
let toLocation: MKMapItem = MKMapItem(placemark: toMKPlacemark)
toLocation.name = "去的地方";
```

GLGeocoder geocoderAddressString CLPlacemark ---> MKPlacemark ---> MKMapItem

```
// MKPlacemark(placemark: CLPlacemark)
// GLGeocoder geocoderAddressString CLPlacemark ---> MKPlacemark ---> MKMapItem
// 获取起点
let startplMK: MKPlacemark = MKPlacemark(placemark: startPLCL)
let startItem: MKMapItem = MKMapItem(placemark: startplMK)
```

MKMapItem 根据起点和终点, 调用系统的地图APP进行导航

```
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
```
### MapKit 导航

MKPlacemark ---> MKMapItem ---> MKDirectionsRequest ---> MKDirections calculate ---> MKDirectionsResponse ---> MKRoute

```
// 创建请求导航路线数据信息
let request: MKDirectionsRequest = MKDirectionsRequest()
request.transportType = .automobile
// 创建起点:根据 CLPlacemark 地标对象创建 MKPlacemark 地标对象
request.source = MKMapItem
// 创建终点:根据 CLPlacemark 地标对象创建 MKPlacemark 地标对象)
request.destination = MKMapItem

// 创建导航对象，根据请求，获取实际路线信息
let directions: MKDirections = MKDirections(request: request)

// 计算路线信息
directions.calculate { (response:MKDirectionsResponse?, error:Error?) in
    if let resp = response {        
        // 遍历 routes （MKRoute对象）：因为有多种路线
        for route: MKRoute in resp.routes {            
            // 添加折线
            self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)            
        }
    }
}
```

MKMapViewDelegate

```
func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    // 折线覆盖层
    if overlay is MKPolyline{
        
        // 创建折线渲染对象 (不同的覆盖层数据模型, 对应不同的覆盖层视图来显示)
        let render: MKPolylineRenderer = MKPolylineRenderer(overlay: overlay)        
        render.lineWidth = 6                // 设置线宽
        render.strokeColor = UIColor.red    // 设置颜色        
        return render

    }
    return MKOverlayRenderer()
}
```

#### 参考

+ location http://www.hangge.com/blog/cache/detail_783.html
+ location http://www.hangge.com/blog/cache/detail_785.html
+ map http://www.hangge.com/blog/cache/detail_787.html
+ location https://www.jianshu.com/nb/4017614