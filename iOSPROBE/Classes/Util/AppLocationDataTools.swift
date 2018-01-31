//
//  AppLocationDataTools.swift
//
//  Created by wangzhikui on 23/12/2017.
//

import Foundation
import UIKit
import CoreLocation

/**
 * App定位信息类
 */
class AppLocationDataTools: NSObject,CLLocationManagerDelegate {

    /** 定位的当前国家 */
    private var _strCurrentCountry:String? = "";
    var strCurrentCountry:String? {
        return _strCurrentCountry;
    }

    /** 定位的当前省份 */
    private var _strCurrentProvince:String? = "";
    var strCurrentProvince:String? {
        return _strCurrentProvince;
    }

    /** 定位的当前城市 */
    private var _strCurrentCity:String? = "";
    var strCurrentCity:String? {
        return _strCurrentCity;
    }

    /** 定位的当前城市所在的区(eg:普陀) */
    private var _strCurrentArea:String?;
    var strCurrentArea:String? {
        return _strCurrentArea;
    }

    /** 定位的当前详细信息 */
    private var _strCurrentAddress:String?;
    var strCurrentAddress:String? {
        return _strCurrentAddress;
    }
    /**
     * 定位信息
     *
     * 经度：currLocation.coordinate.longitude
     * 纬度：currLocation.coordinate.latitude
     * 海拔：currLocation.altitude
     * 方向：currLocation.course
     * 速度：currLocation.speed
     */
    private var _currentLocation:CLLocation?
    var currentLocation:CLLocation? {
        if _currentLocation != nil {
            return _currentLocation!;
        }
        else{
            return nil;
        }
    }
    static var shared = AppLocationDataTools()
    //定位对象
    private static var llocationManager:CLLocationManager?
    //MARK: - 类初始化
    override init() {
        super.init()
        //单例
        if AppLocationDataTools.llocationManager == nil {
            AppLocationDataTools.llocationManager = CLLocationManager()
            AppLocationDataTools.llocationManager?.delegate = self
            //设置精度
            AppLocationDataTools.llocationManager?.desiredAccuracy = kCLLocationAccuracyBest
            //设置间隔距离(单位：m) 内更新定位信息
            //定位要求的精度越高，distanceFilter属性的值越小，应用程序的耗电量就越大。
            AppLocationDataTools.llocationManager?.distanceFilter = 1000.0;
            //如下代码开启的话会在app提示是否允许app使用位置信息。按理不能开启
//            //始终允许访问位置信息
//            AppLocationDataTools.llocationManager?.requestAlwaysAuthorization()
//            //使用应用程序期间允许访问位置数据
//            AppLocationDataTools.llocationManager?.requestWhenInUseAuthorization()
            AppLocationDataTools.llocationManager?.startUpdatingLocation()
        }
    }
    //MARK: - CLLocationManagerDelegate
    //定位失败
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位失败!详见：\(error)");
    }

    //定位成功
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //赋值
        self._currentLocation = locations.last;
        // [S] 反编码以便获取其他信息
        let geoCoder:CLGeocoder = CLGeocoder.init()
        geoCoder.reverseGeocodeLocation(locations.last!, completionHandler: {(placemarks,error) in
            // 如果断网或者定位失败
            if placemarks == nil{
                return
            }
            let placeMark:CLPlacemark = placemarks![0];
            //当前城市(把"市"过滤掉,否则 和 其他界面城市不匹配)
            self._strCurrentCity = placeMark.locality?.replacingOccurrences(of: "市", with: "")
            //详细地址
            self._strCurrentAddress = placeMark.addressDictionary?["FormattedAddressLines"] as? String
            //国家
            self._strCurrentCountry = placeMark.addressDictionary?["Country"] as? String;
            //省份
            self._strCurrentProvince = placeMark.addressDictionary?["State"] as? String
            //区
            self._strCurrentArea = placeMark.addressDictionary?["SubLocality"] as? String
        });
        // [E] 反编码以便获取其他信息
    }

}


