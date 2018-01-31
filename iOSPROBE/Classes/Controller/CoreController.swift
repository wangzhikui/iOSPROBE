//
//  CoreController.swift
//  iOSPROBE
//
//  Created by wangzhikui on 31/01/2018.
//  Copyright © 2018 wangzhikui. All rights reserved.
//

import Foundation

class CoreController : NSObject{
    @objc static let shared = CoreController()
    //定时发送数据和获取地理位置的时间间隔 单位s
    //对于采集到的数据先存储在缓存中，每隔一段时间发送给云端，这里定义时间间隔
    //获取地理位置的时间间隔也一样，当然这里可以自由扩展将两个时间间隔分开定义，获取地理位置的间隔应该长一点
    //手机没有开启定位的话，可以在云端接收到数据的时候通过http的header的来源ip分析位置信息
    private let timeIntervalSendData: Double = 60
    //开启监控
    @objc func openMonitor() {
        //开启网络监控，监控当前网络是否可用
        self.startNetWorkNotifier()
        //开启定时发送数据任务，定时一段时间将数据发送给云端
        self.startTimer()
        //设置代理，所有监控到的数据统一发送到一个代理处理。如果要扩展可以往不同的模块注册自定义的delegate
        //比如crashmonitor，定义的delegate是一个数组
        MonitorManager.shared.delegate =  CoreDelegate.shared
        //打开不同模块的监控
        MonitorManager.shared.openNetworkMonitor()
        MonitorManager.shared.openCrashMonitor()
        MonitorManager.shared.openANRMonitor()
        //hook
        //        UITableView.open()
    }
    //开始监控网络是否可用及连接方式
    @objc func startNetWorkNotifier(){
        //开启网络可用性监控--备注：不是监控应用的网络情况，而是开启一个监控当前网络是否可用，可用的时候才发数据到云端
        do{
            try ReachabilityYYY.shared?.startNotifier()
        } catch {
            //吃掉异常不做任何处理
        }
    }
    //开启发送数据定时任务
    @objc func startTimer(){
        var timer:Timer!
        // 启用计时器，控制每timeInterval秒执行一次方法
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: timeIntervalSendData, repeats: true, block: { (timer) in
                self.timerFuncSendData()
            })
        } else {
            timer = Timer.scheduledTimer(timeInterval: timeIntervalSendData, target: self, selector: #selector(timerFuncSendData), userInfo: nil, repeats: true)
        }
        BaseInfoTools.sendDataTimer = timer
    }
    //定时执行的发送数据的函数，在app启动的时候发送
    @objc private func timerFuncSendData(){
        //判断网络是否可用，可用情况下再发送，否则等待下一次发送
        let conTag = (ReachabilityYYY.shared?.connection.description)!
        if !"noConnection".elementsEqual(conTag){
            self.sendData(key: CacheTools.shared.ANR)
            self.sendData(key: CacheTools.shared.CRASH)
            self.sendData(key: CacheTools.shared.NETWORK)
        }
        //获取位置信息
        self.getLocationInfo()
    }
    //取不同的缓存数据发送，ANR NETWORK CRASH 一般只有NETWORK会存储，ANR和CRASH在崩溃的时候就直接发送
    @objc private func sendData(key:String){
        //发送缓存的数据，这里暂时不做容错，发送失败不再重新发送
        //取缓存
        let cacheData = CacheTools.shared.getCacheDataArray(key: key)
        if cacheData != nil {
            for item in cacheData! {
                NetworkTools.postCommon(jsonStr: item)
            }
            //删除缓存
            CacheTools.shared.removeCacheData(key: key)
        }
    }
    //获取位置信息
    @objc private func getLocationInfo(){
        let province = AppLocationDataTools.shared.strCurrentProvince
        let country = AppLocationDataTools.shared.strCurrentCountry
        let city = AppLocationDataTools.shared.strCurrentCity
        //设置全局的位置信息，位置信息会定时刷新，与发送数据一致
        //设置国家信息
        if country != "" && country != nil {
            BaseInfoTools.country = country!
        }
        //特殊判断，对于直辖市，北京，上海等，是没有省份信息的，这个时候要将province字段也赋值为city的值
        if city != "" && city != nil{
            BaseInfoTools.city = city!
            if province == ""  || province == nil{
                BaseInfoTools.province = city!
            }
        }
        //特殊判断，对于香港，台湾，直接认为是一个省份，不会具体到某一个市，目前的定位，所以要如果没有city，那就将province的信息设置到city字段上
        if province != "" && province != nil{
            BaseInfoTools.province = province!
            if city == "" || city == nil {
                BaseInfoTools.city = province!
            }
        }
    }
}
