//
//  Thread.swift
//
//  Created by wangzhikui on 25/12/2017.
//

import Foundation

extension Thread {
    //获取线程名称 扩展方法都加上yyy前缀防止与应用扩展重名
    @objc var yyyThreadName: String {
        get {
            if self.isMainThread {
                return "main"
            } else if let name = self.name, !name.isEmpty {
                return name
            } else {
                return String(format:"%p", self)
            }
        }
    }
    //获取线程状态
    @objc var yyyThreadStatus: String{
        get {
            if self.isFinished {
                return "FINISHED"
            } else if self.isExecuting {
                return "RUNNABLE"
            } else {
                return "CANCELLED"
            }
        }
    }
}

