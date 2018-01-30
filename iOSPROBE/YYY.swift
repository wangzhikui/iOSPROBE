//
//  yyy.swift
//  对外暴露的类
//  Created by 王智魁 on 25/12/2017.
//

import Foundation
open class YYY: NSObject {
    //对外暴露的方法，在此方法中做一些基本的初始化工作
    @objc open class func openMonitor(tid:String,appid:String) {
        //初始化租户id  tid 应用id appid
        BaseInfoTools.tid = tid
        BaseInfoTools.appid = appid
        //初始化发送云端服务器地址
        NetworkTools.host = "ycm.yonyou.com"
        NetworkTools.url = "http://ycm.yonyou.com/send/api/mobile"
        //初始化探针版本和名称
        BaseInfoTools.agentName = "iOSPROBE"
        BaseInfoTools.agentVersion = "1.0.0.20180109_beta"
        //发送app和device数据到云端
        BaseInfoTools.sendAppInfo(tid: tid, appid: appid)
        BaseInfoTools.sendDeviceInfo(tid: tid, appid: appid)
//        UITableView.open()
        //打开监控，首先判断是否可以发送数据，该标志位会在每次发送数据到云端的返回信息中获取并更新
        if BaseInfoTools.isDataCanSend {
            YYYController.shared.openMonitor()
        }
    }
}
