//
//  CacheTools.swift
//  iOSPROBE
//  使用UserDefaults，可以修改成使用归档或者其他方式
//  Created by wangzhikui on 28/12/2017.
//  Copyright © 2017 wangzhikui. All rights reserved.
//

import Foundation

class CacheTools{
    
    static let shared = CacheTools()
    let NETWORK = "network"
    let ANR = "anr"
    let CRASH = "crash"
    
    // 写缓存 使用 UserDefaults方式
    func saveCacheDataArray(data:[String], key :String) {
        let setting = UserDefaults.standard
        setting.set(data, forKey: key)
        setting.synchronize()
    }
    // 读缓存
    func getCacheDataArray(key : String) -> [String]? {
        let setting = UserDefaults.standard
        return setting.object(forKey: key) as? [String]
    }
    // 删缓存
    func removeCacheData(key : String) {
        let setting = UserDefaults.standard
        setting.removeObject(forKey: key)
        setting.synchronize()
    }
    //移除所有缓存 不能直接清空UserDefault，因为被监控的app会用到
    func removeAllCacheData(){
        self.removeCacheData(key: self.ANR)
        self.removeCacheData(key: self.CRASH)
        self.removeCacheData(key: self.NETWORK)
    }
    //为了存储业务数据方便而抽象的一个方法，存入的是数组，这里传入的是一个String所以需要追加操作
    func setCacheForBusi(value : String,key:String){
        //判断缓存是否存在，存在的话要将String类型的value追加到缓存的array（缓存中预制存储的是array）
        var cacheData = self.getCacheDataArray(key: key)
        if cacheData == nil {
            let valueArry = [value]
            self.saveCacheDataArray(data: valueArry, key: key)
        } else {
            cacheData?.append(value)
            self.removeCacheData(key: key)
            self.saveCacheDataArray(data: cacheData!, key: key)
        }
    }
}
