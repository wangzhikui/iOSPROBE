//
//  CoreDelegate.swift
//  iOSPROBE
//
//  Created by wangzhikui on 18/01/2018.
//  Copyright © 2018 wangzhikui. All rights reserved.
//

import Foundation


class CoreDelegate:NSObject {
    @objc static let shared = CoreDelegate()
}

//MARK: - NetworkEye
extension CoreDelegate: NetworkMonitorDelegate {
    func networkMonitorDispatch(with request:URLRequest?,response:URLResponse?,data:Data?, useTime:Int?) {
        //判断如果是探针发送云端的请求则不需要记录
        let tid = BaseInfoTools.tid //租户id
        let appid = BaseInfoTools.appid //应用id
        let requestURLString = request?.url?.absoluteString
        if (requestURLString?.contains(NetworkTools.host))!{
            return
        }
        let model = NetworkModel(request: request, response: response as? HTTPURLResponse, data: data)
        let bytercv = model.responseExpectedContentLength //接收到的字段长度标记
        //计算发送数据的长度 带的request里边没有直接的长度信息，这里计算headfield+httpbody+url的长度 有的数据是直接包含在url里边，所以这里计算一下url长度
        var headFieldsLength: Int = 0
        if model.requestAllHTTPHeaderFields !=  nil {
            headFieldsLength = (model.requestAllHTTPHeaderFields?.lengthOfBytes(using: String.Encoding.utf8))!
        }
        var httpBodyLength: Int = 0
        if model.requestHTTPBody !=  nil {
            httpBodyLength = (model.requestHTTPBody?.lengthOfBytes(using: String.Encoding.utf8))!
        }
        let requestURLSTringByteLength: Int = (model.requestURLString?.lengthOfBytes(using: String.Encoding.utf8))!
        let bytesent = headFieldsLength + httpBodyLength + requestURLSTringByteLength //发送数据长度 ???
        let deviceid = BaseInfoTools.identifierNumber! //设备唯一标识
        let error = 0 //错误码 ???
        let method = model.requestHTTPMethod! //发送方式，post or get
        let status = model.responseStatusCode //状态码
        let total = useTime //总耗时
        let url = model.requestURLString! //请求的url地址
        let wan = ReachabilityYYY.shared?.connection.description //网络接入方式
        var carrier = CarrierInfoTools.shared.carrierName //网络服务提供商
        if wan == "wifi"{
            carrier = "wifi"
        }
        let ts = BaseInfoTools.getTsMS()
        let jsonStr = "[{\"header\":{\"tid\": \"\(tid)\", \"appid\": \"\(appid)\",\"pt\":\"httptxn\", \"srid\":\"-1\", \"platform\":\"ios\" }, \"content\":[{\"bytercv\": \(bytercv), \"bytesent\": \(bytesent), \"carrier\": \"\(carrier)\", \"deviceid\": \"\(deviceid)\", \"error\": \(error), \"method\": \"\(String(describing: method))\", \"status\": \(status), \"total\": \(total!),\"url\": \"\(url)\", \"wan\": \"\(String(describing: wan!))\", \"ts\": \(ts) }] }]"
        //加入任务队列
        //CacheTools.shared.setCacheForBusi(value: jsonStr, key: CacheTools.shared.NETWORK)
        //直接发送请求
//        NetworkTools.postCommon(jsonStr: jsonStr)
        print(jsonStr)
    }
}
//MARK: - CrashEye
extension CoreDelegate: CrashMonitorDelegate {
    @objc func crashMonitorDispatch(with model:CrashModel) {
        //将数据发送给云端
        let tid = BaseInfoTools.tid //租户id
        let appid = BaseInfoTools.appid //应用id
        let name: String = model.name //崩溃类型名称
        let reason: String = model.reason //原因 对应 json中的cause
        let stackArray = model.callStackArray //堆栈，数组
        let ts = BaseInfoTools.getTsMS() //时间戳 秒
        let uuid = UUID().uuidString   //记录的id ???
        //app
        let bundleIdentifier = BaseInfoTools.getAppInfo(type: "bundleIdentifier") // 包
        let build = BaseInfoTools.getAppInfo(type: "minorVersion") //xcode设置项目的build  内部版本标识
        let displayName = BaseInfoTools.getAppInfo(type: "displayName") //应用名称
        let appVersion = BaseInfoTools.getAppInfo(type: "appVersion") //应用版本
        //device
        let deviceid = BaseInfoTools.identifierNumber! //设备唯一标识
        let hostip = BaseInfoTools.getHostIp() // 连接wifi就获取wifi，wan就获取手机
        //获取地址
        let province = BaseInfoTools.province
        let city = BaseInfoTools.city
        //disk
        let root = DiskInfoTools.shared.getFreeDiskSpace() //获取本地硬盘剩余容量 byte
        let dvname = BaseInfoTools.modelName //手机具体型号名称 iphone 6s
        //获取系统内存使用率
        let ramSysUsage = System.memory.systemUsage()
        let percent = (ramSysUsage.active + ramSysUsage.inactive + ramSysUsage.wired) / ramSysUsage.total
        let memory = percent * 100.0 //内存使用率
        let netsts = (ReachabilityYYY.shared?.connection.description)! //wifi还是非wifi
        let osver = BaseInfoTools.iosVersion //系统版本
        //thread 目前只采集当前运行线程数据，其他线程数据待定
        let id = (model.threadName)!
        let number = 0;
        let priority = model.threadPriority
        let state = (model.threadStatus)!
        //thread->stack 堆栈信息不能按照原来的格式拆分成class file line method，ios采集的是一条数据，所以这里就直接放到class，其他字段为空
        var index: Int = 0
        var stack: String = "["
        for item in stackArray! {
            index = index + 1
            var temp: String =  "{\"class\": \"\(item.replacingOccurrences(of: "\n", with: ""))\",\"file\": \"\",\"lineno\": 0,\"method\": \"\"}"
            if index < (stackArray?.count)!{
                temp.append(",")
            }
            stack.append(temp)
        }
        stack.append("]")
        //如果获取不到位置信息则在header中增加"ip":"#~#~#~"
        var jsonStr = "[ {\"content\": [ {\"activity\": [], \"app\": {\"build\": \"\(build)\", \"bundle\": \"\(bundleIdentifier)\", \"name\": \"\(displayName)\",\"ver\": \"\(appVersion)\" },\"device\": {\"deviceid\": \"\(deviceid)\", \"hostip\":\"\(String(describing: hostip!))\", \"province\":\"\(province)\", \"city\":\"\(city)\", \"disk\": {\"root\": \(root) }, \"dvname\": \"\(dvname)\", \"memory\": \(memory), \"model\": \"\", \"netsts\": \"\(netsts)\", \"osver\": \"\(osver)\"}, \"ex\": {\"cause\": \"\(reason)\", \"name\": \"\(name)\" }, \"platform\": \"ios\", \"thread\": [ {\"crashed\": true, \"id\": \"\(String(describing: id))\", \"number\": \(number), \"priority\": \(priority ?? 0), \"stack\": \(stack), \"state\": \"\(String(describing: state))\" }], \"ts\": \(ts), \"uuid\": \"\(uuid)\" }], \"header\": {\"appid\": \"\(appid)\", \"platform\": \"ios\", \"pt\": \"crash\", \"srid\": \"-1\", \"tid\": \"\(tid)\""
        if province == ""{
            jsonStr = jsonStr.appending(",\"ip\": \"#~#~#~\"")
        }
        jsonStr = jsonStr.appending("} }]")
        //加入任务队列
        //CacheTools.shared.setCacheForBusi(value: jsonStr, key: CacheTools.shared.CRASH)
        //直接发送请求
//        NetworkTools.postCommon(jsonStr: jsonStr)
        print(jsonStr)
        
    }
}
//MARK: - ANREye
extension CoreDelegate: ANRMonitorDelegate {
    //ANREye的回调
    func anrMonitorDispatch(catchWithThreshold threshold:Double,mainThreadBacktrace:String?,allThreadBacktrace:String?) {
        //拼接成字符串向外发送
        let tid = BaseInfoTools.tid //租户id
        let appid = BaseInfoTools.appid //应用id
        let displayName = BaseInfoTools.getAppInfo(type: "displayName") //应用名称
        let appVersion = BaseInfoTools.getAppInfo(type: "appVersion") //应用版本
        let iosVersion = BaseInfoTools.iosVersion //系统版本
        let agentName = BaseInfoTools.agentName //探针名称
        let agentVersion = BaseInfoTools.agentVersion //探针版本
        let identifierNumber = BaseInfoTools.identifierNumber! //设备唯一标识
        let modelName = BaseInfoTools.modelName //手机具体型号名称 iphone 6s
        let ts = BaseInfoTools.getTsMS() //时间戳
        let totalSpace = DiskInfoTools.shared.getTotalDiskSpace() //总容量 byte
        let freeSpace = DiskInfoTools.shared.getFreeDiskSpace() //可用容量 byte
        //获取系统内存数据
        let totalMemory = System.memory.systemUsage().total //总内存  byte
        let freeMemory = System.memory.systemUsage().free //可用内存 byte
        //获取地区
        let province = BaseInfoTools.province
        let city = BaseInfoTools.city
        //格式化堆栈信息，去掉\n
        let mainThreadBacktraceFormat = mainThreadBacktrace?.replacingOccurrences(of: "\n", with: "\\n")
        let allThreadBacktraceFormat = allThreadBacktrace?.replacingOccurrences(of: "\n", with: "\\n")
        
        let uuid = UUID().uuidString
        //如果获取不到位置信息则在header中增加"ip":"#~#~#~"
        var jsonStr = "[ {\"header\": {\"tid\": \"\(tid)\", \"appid\": \"\(appid)\", \"pt\": \"anr\", \"srid\": \"-1\", \"platform\": \"ios\", \"name\": \"\(displayName)\", \"version\": \"\(appVersion)\", \"packageid\": \"\", \"osname\": \"ios\", \"osversion\": \"\(iosVersion)\", \"model\": \"\", \"agentname\": \"\(agentName)\", \"agentver\": \"\(agentVersion)\", \"deviceid\": \"\(String(describing: identifierNumber))\", \"province\": \"\(province)\", \"city\": \"\(city)\", \"manufacturer\": \"\(modelName)\""
        if province == ""{
            jsonStr = jsonStr.appending(",\"ip\": \"#~#~#~\"")
        }
        jsonStr = jsonStr.appending("}, \"content\": [ {\"uuid\": \"\(uuid)\", \"pid\": \(threshold), \"describe\": \"\", \"occurpackage\": \"\", \"stacktrace\": \"\(String(describing: mainThreadBacktraceFormat!))\", \"occurlocation\": \"\", \"otherthreads\": \"\(String(describing: allThreadBacktraceFormat!))\", \"trace\": \"\", \"message\": \"\", \"ts\": \(ts), \"root\": false, \"sdcardtotal\": 0, \"sdcardavai\": 0, \"totalspace\": \(totalSpace), \"freespace\": \(freeSpace), \"totalmemory\": \(totalMemory), \"freememory\": \(freeMemory) }] }]")
        //加入任务队列
        //CacheTools.shared.setCacheForBusi(value: jsonStr, key: CacheTools.shared.ANR)
        //直接发送请求
//        NetworkTools.postCommon(jsonStr: jsonStr)
        print(jsonStr)
    }
}
