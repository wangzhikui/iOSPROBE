//
//  CrashModel.swift
//  iOSPROBE
//
//  Created by 王智魁 on 18/01/2018.
//  Copyright © 2018 wangzhikui. All rights reserved.
//

import Foundation

open class CrashModel: NSObject {
    
    open var type: String! //崩溃类型 异常exception或者信号量 signal
    open var name: String! //崩溃类型名称
    open var reason: String! //崩溃原因
    open var callStack: String! //堆栈信息 字符串类型
    open var callStackArray: [String]! //堆栈信息 数组类型
    open var threadName: String! // 线程名称
    open var threadPriority: Double! //线程优先级
    open var threadStatus: String! //线程运行状态
    
    init(type:String,
         name:String,
         reason:String,
         callStack:String,
         callStackArray:[String],
         threadName:String,
         threadPriority:Double,
         threadStatus:String) {
        super.init()
        self.type = type
        self.name = name
        self.reason = reason
        self.callStack = callStack
        self.callStackArray = callStackArray
        self.threadName = threadName
        self.threadPriority = threadPriority
        self.threadStatus = threadStatus
    }
}
