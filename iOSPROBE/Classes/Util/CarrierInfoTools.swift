//
//  CarrierInfoTools.swift
//  iOSPROBE
//  获取运营商信息工具类
//  Created by 王智魁 on 30/12/2017.
//  Copyright © 2017 wangzhikui. All rights reserved.
//

import Foundation
import CoreTelephony

class CarrierInfoTools:NSObject {
    //对外提供的访问
    static let shared = CarrierInfoTools()
    
    var currentRadioTech = "" //数据业务信息
    var networkType = "" //网络制式
    var carrierName = "" //运营商名字
    var mobileCountryCode = "" //移动国家码(MCC)
    var mobileNetworkCode = "" //移动网络码(MNC)
    var isoCountryCode = "" //ISO国家代码
    var allowsVOIP = false //是否允许VoIP（网络电话）
    
    override init() {
        super.init()
        //初始化运营商信息
        let networkInfo = CTTelephonyNetworkInfo()
        if let carrier = networkInfo.subscriberCellularProvider {
            let currentRadioTech = networkInfo.currentRadioAccessTechnology!
            self.currentRadioTech = currentRadioTech
            self.networkType = self.getNetworkTypeByCurrentRadioTech(currentRadioTech: currentRadioTech)
            self.carrierName = carrier.carrierName!
            self.mobileCountryCode = carrier.mobileCountryCode!
            self.mobileNetworkCode = carrier.mobileNetworkCode!
            self.isoCountryCode = carrier.isoCountryCode!
            self.allowsVOIP = carrier.allowsVOIP
        }
    }
    //根据数据业务信息获取对应的网络类型
    func getNetworkTypeByCurrentRadioTech(currentRadioTech:String) -> String {
        var networkType = ""
        switch currentRadioTech {
        case CTRadioAccessTechnologyGPRS:
            networkType = "2G"
        case CTRadioAccessTechnologyEdge:
            networkType = "2G"
        case CTRadioAccessTechnologyeHRPD:
            networkType = "3G"
        case CTRadioAccessTechnologyHSDPA:
            networkType = "3G"
        case CTRadioAccessTechnologyCDMA1x:
            networkType = "2G"
        case CTRadioAccessTechnologyLTE:
            networkType = "4G"
        case CTRadioAccessTechnologyCDMAEVDORev0:
            networkType = "3G"
        case CTRadioAccessTechnologyCDMAEVDORevA:
            networkType = "3G"
        case CTRadioAccessTechnologyCDMAEVDORevB:
            networkType = "3G"
        case CTRadioAccessTechnologyHSUPA:
            networkType = "3G"
        default:
            break
        }
        return networkType
    }
    
}
