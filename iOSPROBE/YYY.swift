//
//  yyy.swift
//  对外暴露的类
//  Created by 王智魁 on 25/12/2017.
//

import Foundation
open class YYY: NSObject {
    //对外暴露的方法，在此方法中做一些基本的初始化工作，这里可以传入app的一些参数，如唯一标识app的appid，和token校验码 tid
    @objc open class func openMonitor(tid:String,appid:String) {
        //初始化租户id  tid 应用id appid
        BaseInfoTools.tid = tid
        BaseInfoTools.appid = appid
        //初始化发送云端服务器地址，host是在网络监控的时候用来判断获取到的url地址是不是我们自己的地址
        //探针发送数据到服务器的过程不需要监控
        NetworkTools.host = "www.wushuning.com"
        //云端接收数据的地址
        NetworkTools.url = "http://www.wushuning.com/send/api/mobile"
        //anr判定的阀值 传入2s
        BaseInfoTools.threadhold = 2.0
        //初始化探针版本和名称
        BaseInfoTools.agentName = "iOSPROBE"
        BaseInfoTools.agentVersion = "1.0.0.20180109_beta"
        //发送app和device数据到云端 探针启动的时候就发送，这里可以根据自己的需要修改
        BaseInfoTools.sendAppInfo(tid: tid, appid: appid)
        BaseInfoTools.sendDeviceInfo(tid: tid, appid: appid)
//        UITableView.open()
        //打开监控，首先判断是否可以发送数据，该标志位会在，每次发送数据到云端的返回信息中获取并更新
        if BaseInfoTools.isDataCanSend {
            YYYController.shared.openMonitor()
        }
    }
}
