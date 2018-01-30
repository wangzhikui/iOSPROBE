//
//  ANRMonitor.swift
//  iOSPROBE
//  开启一个线程ping主线程，如果在给定的时间内没有回应则说明主线程阻塞，即定为发生了卡顿
//  Created by wangzhikui on 29/01/2018.
//  Copyright © 2018 wangzhikui. All rights reserved.
//

import Foundation

@objc public protocol ANRMonitorDelegate: class {
    @objc optional func anrMonitorDispatch(catchWithThreshold threshold:Double,mainThreadBacktrace:String?,allThreadBacktrace:String?)
}

open class ANRMonitor: NSObject {
    open weak var delegate: ANRMonitorDelegate?
    open var isOpen: Bool {
        get {
            guard let pingThread = self.pingThread else {
                return false
            }
            return !pingThread.isCancelled
        }
    }
    //开启监控，传入阀值 单位s
    open func startMonitor(with threshold:Double) {
        if Thread.current.isMainThread {
            AppBacktrace.main_thread_id = mach_thread_self()
        }else {
            DispatchQueue.main.async {
                AppBacktrace.main_thread_id = mach_thread_self()
            }
        }
        self.pingThread = AppPingThread()
        self.pingThread?.start(threshold: threshold, handler: { [weak self] in
            guard let sself = self else {
                return
            }
            let main = AppBacktrace.mainThread()
            let all = AppBacktrace.allThread()
            sself.delegate?.anrMonitorDispatch?(catchWithThreshold: threshold, mainThreadBacktrace: main,allThreadBacktrace: all)
        })
    }
    //停止监控
    open func stopMonitor() {
        self.pingThread?.cancel()
    }
    deinit {
        self.pingThread?.cancel()
    }
    private var pingThread: AppPingThread?
}

public typealias AppPingThreadCallBack = () -> Void

//用来ping主线程的线程类
private class AppPingThread: Thread {
    
    func start(threshold:Double, handler: @escaping AppPingThreadCallBack) {
        self.handler = handler
        self.threshold = threshold
        self.start()
    }
    
    override func main() {
        //如果ping线程没有消亡则一直循环
        while self.isCancelled == false {
            //先将主线程卡顿标志设置为卡顿
            self.isMainThreadBlock = true
            //ping主线程
            DispatchQueue.main.async {
                //ping通则将主线程卡顿标志设置为不卡顿
                self.isMainThreadBlock = false
                //信号资源+1
                self.semaphore.signal()
            }
            //ping线程睡眠给定的阀值时间
            Thread.sleep(forTimeInterval: self.threshold)
            //判断主线程卡顿标志，如果卡顿则调用给定的回调函数
            if self.isMainThreadBlock  {
                self.handler?()
            }
            //信号资源-1
            _ = self.semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
    //持有计数的信号
    private let semaphore = DispatchSemaphore(value: 0)
    //主线程是否阻塞,初始不卡顿
    private var isMainThreadBlock = false
    //卡顿阀值
    private var threshold: Double = 1
    //回调函数，线程结束后的回调
    fileprivate var handler: (() -> Void)?
}
