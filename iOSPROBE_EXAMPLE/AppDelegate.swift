//
//  AppDelegate.swift
//  iOSPROBE_EXAMPLE
//
//  Created by 王智魁 on 28/12/2017.
//  Copyright © 2017 友云音. All rights reserved.
//
import UIKit
import iOSPROBE

func alert(t:String, _ m:String) {
    let alertView = UIAlertView()
    alertView.title = t
    alertView.message = m
    alertView.addButton(withTitle: "OK")
    alertView.show()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        YYY.openMonitor(tid:"FtxuKMUUYm7901010000",appid:"isYGhdQJgf05394240000")
        return true
    }
}

