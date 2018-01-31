//
//  MonitorManager.swift
//  iOSPROBE
//
//  Created by wangzhikui on 18/01/2018.
//  Copyright © 2018 wangzhikui. All rights reserved.
//

import Foundation

class MonitorManager: NSObject {
    @objc static let shared = MonitorManager()
    @objc weak var delegate:CoreDelegate?
    
    fileprivate lazy var anrMonitor: ANRMonitor = { [unowned self] in
        let new = ANRMonitor()
        new.delegate = self.delegate
        return new
        }()
}

extension MonitorManager {
    @objc func isCrashMonitorStart() -> Bool {
        return CrashMonitor.isStart
    }
    @objc func openCrashMonitor() {
        //添加接收数据的代理
        CrashMonitor.addMonitorDelegate(delegate: self.delegate!)
    }
    @objc func closeCrashMonitor() {
        CrashMonitor.removeMonitorDelegate(delegate: self.delegate!)
    }
}

extension MonitorManager {
    @objc func isNetworkMonitorStart() -> Bool {
        return NetworkMonitor.isStart
    }
    @objc func openNetworkMonitor() {
        NetworkMonitor.addMonitorDelegate(delegate: self.delegate!)
    }
    @objc func closeNetworkMonitor() {
        NetworkMonitor.removeMonitorDelegate(delegate: self.delegate!)
    }
}

extension MonitorManager {
    @objc func openANRMonitor() {
        //传入阀值 2s
        self.anrMonitor.startMonitor(with: BaseInfoTools.threadhold)
    }
    @objc func closeANRMonitor() {
        self.anrMonitor.stopMonitor()
    }
}
