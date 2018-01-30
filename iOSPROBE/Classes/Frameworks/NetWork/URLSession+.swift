//
//  URLSession+.swift
//  通过hook 类 URLSession中init方法在其中将我们的监控处理类注册进去
//  Created by wangzhikui on 25/12/2017.
//

import Foundation

extension URLSession {
    //convenience（方便）  编写一个方便构造函数 然后与原有的init交换
    //在init方法中将我们自己的处理类注册进去
    convenience init(configurationMonitor: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?) {
        if configurationMonitor.protocolClasses != nil {
            configurationMonitor.protocolClasses!.insert(MonitorProtocol.classForCoder(), at: 0)
        }else {
            configurationMonitor.protocolClasses = [MonitorProtocol.classForCoder()]
        }
        //在我们自己编写的构造函数里边调用自己，这里并没有递归，因为交换了方法之后，这里调用的实际是原来的init方法而不是我们自己写的这个init
        self.init(configurationMonitor: configurationMonitor, delegate: delegate, delegateQueue: queue)
    }
    
    class func startMonitor() {
        if self.isSwizzled == false && self.hook() == .Succeed {
            self.isSwizzled = true
        }
    }
    
    class func stopMonitor() {
        if self.isSwizzled == true && self.hook() == .Succeed {
            self.isSwizzled = false
        }
    }
    //hook URLSession的init方法
    private class func hook() -> SwizzleResult {
        let orig = Selector("initWithConfiguration:delegate:delegateQueue:")
        let alter = #selector(URLSession.init(configurationMonitor:delegate:delegateQueue:))
        let result = URLSession.swizzleInstanceMethod(origSelector: orig, toAlterSelector: alter)
        return result
    }
    //获取是否已经hook的标识，通过oc的关联对象存储hook标识
    private static var isSwizzled:Bool {
        set{
            objc_setAssociatedObject(self, &key.isSwizzled, isSwizzled, .OBJC_ASSOCIATION_ASSIGN);
        }
        get{
            let result = objc_getAssociatedObject(self, &key.isSwizzled) as? Bool
            if result == nil {
                return false
            }
            return result!
        }
    }
    
    private struct key {
        static var isSwizzled: Character = "c"
    }
}
