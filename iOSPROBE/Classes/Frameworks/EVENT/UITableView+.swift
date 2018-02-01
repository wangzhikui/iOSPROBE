//
//  UITableView.swift
//  iOSPROBE
//
//  Created by 王智魁 on 04/01/2018.
//  Copyright © 2018 wangzhikui. All rights reserved.
//

import Foundation

extension UITableView {
    
    func setDelegateHook( delegate:UITableViewDelegate){
//        let orig_setDelegate = #selector(delegate.tableView(_:didSelectRowAt:))
//        let alter_setDelegate = #selector(UITableView.tableViewHook(_:didSelectRowAt:))
//        let altMethod: Method = class_getInstanceMethod(self.classForCoder, alter_setDelegate)
//        let origMethod: Method = class_getInstanceMethod(delegate.superclass, orig_setDelegate)
//        method_exchangeImplementations(origMethod, altMethod)
        self.delegate = delegate
    }

    class func open() {
        _ = self.hookSetDelegate()
    }
    
    private class func hookSetDelegate() -> SwizzleResult {
        let orig_setDelegate = #selector(setter: UITableView.delegate)
        let alter_setDelegate = #selector(UITableView.setDelegateHook(delegate:))
        let result = UITableView.swizzleInstanceMethod(origSelector: orig_setDelegate, toAlterSelector: alter_setDelegate)
//        let orig = Selector("setDelegate:tableView:didSelectRowAtIndexPath:")
//        let alter = #selector(URLSession.init(configurationMonitor:delegate:delegateQueue:))
//        let result = URLSession.swizzleInstanceMethod(origSelector: orig, toAlterSelector: alter)
        return result
    }
   @objc public func tableViewHook(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print(indexPath)
    
        self.tableViewHook(tableView, didSelectRowAt: indexPath)
    }
    
}




