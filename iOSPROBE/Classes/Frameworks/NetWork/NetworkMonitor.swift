//
//  NetWorkMonitor.swift
//  iOSPROBE
//  网络监控有：URLSession发起的请求和其他urlconnecton发起的请求两种监控不一样，所以在该类统一管理两种监控的开启和关闭等
//  Created by wangzhikui on 18/01/2018.
//  Copyright © 2018 wangzhikui. All rights reserved.
//

import Foundation

//通信协议对象
public protocol NetworkMonitorDelegate: NSObjectProtocol {
    func networkMonitorDispatch(with request:URLRequest?,response:URLResponse?,data:Data?,useTime:Int?)
}

class WeakNetworkMonitorDelegate: NSObject {
    weak var delegate : NetworkMonitorDelegate?
    init (delegate: NetworkMonitorDelegate) {
        super.init()
        self.delegate = delegate
    }
}

open class NetworkMonitor: NSObject {
    open static var isStart: Bool  {
        get {
            return MonitorProtocol.weekDelegates.count > 0
        }
    }
    //添加一个监听对象
    open class func addMonitorDelegate(delegate:NetworkMonitorDelegate) {
        if MonitorProtocol.weekDelegates.count == 0 {
            //普通网络请求监控
            MonitorProtocol.startMonitor()
            //urlsession发起的网络监控
            URLSession.startMonitor()
        }
        MonitorProtocol.addMonitorDelegate(delegate: delegate)
    }
    //移除一个网络监听代理对象，如果一个都没有了则关闭网络监控
    open class func removeMonitorDelegate(delegate:NetworkMonitorDelegate) {
        MonitorProtocol.removeMonitorDelegate(delegate: delegate)
        if MonitorProtocol.weekDelegates.count == 0 {
            MonitorProtocol.stopMonitor()
            URLSession.stopMonitor()
        }
    }
}
