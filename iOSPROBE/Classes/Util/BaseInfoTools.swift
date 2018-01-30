//
//  BaseInfoTools.swift
//
//  Created by wangzhikui on 22/12/2017.
//

import Foundation

class BaseInfoTools{
    
    //设备信息
    static let iosVersion = UIDevice.current.systemVersion //iOS版本
    static let identifierNumber = UIDevice.current.identifierForVendor //设备udid
    static let systemName = UIDevice.current.systemName //设备名称
    static let model = UIDevice.current.model //设备型号
    static let modelName = UIDevice.current.modelName //设备具体型号
    static let localizedModel = UIDevice.current.localizedModel //设备区域化型号如A1533
    //探针基本信息，探针的名称和版本，发送到云端的信息中要带上这两个字段,在探针初始化的时候设置目前在YYY.swift中设置
    static var agentName = ""
    static var agentVersion = ""
    static var tid = ""
    static var appid = ""
    //位置信息 app启动的时候就开始获取位置信息，并且没隔一段时间获取一次，但是app内不会提示用户开启
    //获取位置主要是为了分析访问的地域信息，如果用户没有开启定位，可以云端接收到信息后根据来源ip分析是哪个地方的地址
    static var country = "" //国家
    static var province = "" //省份
    static var city  = "" //城市
    //是否可以发送数据的标识，改值默认是true，当第一次发送云端请求返回的结果中提示不用发送了，则修改为false，可能是租户停用了，也可能是应用删除了等
    static var isDataCanSend = true
    //发送数据的定时任务实例，全局保存，便于停止
    static var sendDataTimer:Timer!
    //停止所有监控
    class func stopMonitor(){
        //将是否能发送数据标志设置为 false
        BaseInfoTools.isDataCanSend = false
        //关闭监控
        MonitorManager.shared.closeANRMonitor()
        MonitorManager.shared.closeCrashMonitor()
        MonitorManager.shared.closeNetworkMonitor()
        //停止定时任务
        BaseInfoTools.sendDataTimer.invalidate()
        //关闭网络状态监控
        ReachabilityYYY.shared?.stopNotifier()
        //清理缓存的要发送的数据
        CacheTools.shared.removeAllCacheData()
    }
    //获取应用信息
    class func getAppInfo(type:String)->String{
        //应用程序信息
        let infoDictionary = Bundle.main.infoDictionary!
        
        switch type {
        case "displayName" :
            return infoDictionary["CFBundleDisplayName"] == nil ? "" : infoDictionary["CFBundleDisplayName"]as! String //主程序M名称
        case "appVersion" :
            return infoDictionary["CFBundleShortVersionString"] == nil ? "" : infoDictionary["CFBundleShortVersionString"]as! String //主程序版本号
        case "minorVersion" :
            return infoDictionary["CFBundleVersion"] == nil ? "" : infoDictionary["CFBundleVersion"]as! String //版本号（内部标示  对应 xcode中设置build）
        case "bundleIdentifier" :
            return Bundle.main.bundleIdentifier!
        default:  return type
        }
    }
    //MARK: 发送app信息到服务器
    class func sendAppInfo(tid:String,appid:String){
        //拼接成字符串向外发送 wangzhk
        let displayName = self.getAppInfo(type: "displayName")
        let appVersion = self.getAppInfo(type: "appVersion")
        let jsonStr = "[{\"header\":{ \"tid\":\"\(tid)\",\"appid\":\"\(appid)\",\"pt\":\"app\",\"srid\":\"-1\",\"platform\":\"ios\"},\"content\":[{\"name\": \"\(displayName)\",\"packageid\": \"\",\"version\": \"\(appVersion)\"}]}]"
        NetworkTools.postCommon(jsonStr: jsonStr)
    }
    //MARK: 发送手机信息到服务器
    class func sendDeviceInfo(tid:String,appid:String){
        let ip = self.getHostIp()
        //分辨率
        let rect : CGRect = UIScreen.main.bounds
        let size : CGSize = rect.size
        let scale : CGFloat = UIScreen.main.scale
        let width = Int(size.width*scale)
        let height = Int(size.height*scale)
        //获取地址
        let province = BaseInfoTools.province
        let city = BaseInfoTools.city
        let jsonStr = "[ {\"header\": {\"tid\": \"\(tid)\", \"appid\": \"\(appid)\", \"pt\": \"device\", \"srid\": \"-1\", \"platform\": \"ios\" }, \"content\": [ {\"agentame\": \"\(agentName)\", \"agentver\": \"\(agentVersion)\", \"country\": \"\", \"deviceid\": \"\(String(describing: identifierNumber!))\", \"manufacturer\": \"\(modelName)\", \"misc\": {\"platform\": \"\", \"platver\": \"\", \"size\": \"\" }, \"model\": \"\", \"osname\": \"ios\", \"osversion\": \"\(iosVersion)\", \"region\": \"\", \"hostip\": \"\(String(describing: ip!))\", \"province\": \"\(province)\", \"city\": \"\(city)\", \"width\": \(width), \"heigth\": \(height) }] }]"
        NetworkTools.postCommon(jsonStr: jsonStr)
    }
    //MARK: 获取ip地址 如果获取不到则返回 #.#.#.#
    class func getHostIp() -> String? {
        var ip = "#.#.#.#"
        //连接wifi就获取wifiip，否则获取手机ip，不联网则返回#.#.#.#
        let conType = (ReachabilityYYY.shared?.connection.description)!
        if "wifi".elementsEqual(conType){//wifi
            ip = NetObjc.wifiIPAddress()!
        } else if "cellular".elementsEqual(conType) {//wan
            ip = NetObjc.cellIPAddress()!
        }
        return ip
    }
    //获取当前电量
    class func getBattery() ->Float{
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        UIDevice.current.isBatteryMonitoringEnabled = false
        return batteryLevel
    }
    //MARK: 获取时间戳 秒
    class func getTs()->Int{
        let date = NSDate()
        let ts = Int(date.timeIntervalSince1970)
       return ts
    }
    //MARK: 获取时间戳 毫秒
    class func getTsMS()->Int{
        let date = NSDate()
        let ts = Int(date.timeIntervalSince1970 * 1000)
        return ts
    }
    //MARK: 将json字符串转字典类型
    class func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    //MARK: 将jsonData转字典类型
    class func getDictionaryFromJSONData(jsonData:Data) ->NSDictionary{
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    //MARK: 将字典转json字符串
    class func getJSONStringFromDictionary(dictionary:NSDictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData!
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }
    //MARK: 将data类型转成json字符串
    class func getJSONSTringFromData(from data:Data?) -> String? {
        guard let data = data else {
            return nil
        }
        do {
            let returnValue = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard JSONSerialization.isValidJSONObject(returnValue) else {
                return nil;
            }
            let data = try JSONSerialization.data(withJSONObject: returnValue)
            return String(data: data, encoding: .utf8)
        } catch  {
            return nil
        }
    }
}

//MARK: - UIDevice延展
public extension UIDevice {
    
    @objc var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod1,1":  return "iPod Touch 1"
        case "iPod2,1":  return "iPod Touch 2"
        case "iPod3,1":  return "iPod Touch 3"
        case "iPod4,1":  return "iPod Touch 4"
        case "iPod5,1":  return "iPod Touch (5 Gen)"
        case "iPod7,1":   return "iPod Touch 6"
            
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":  return "iPhone 4"
        case "iPhone4,1":  return "iPhone 4s"
        case "iPhone5,1":   return "iPhone 5"
        case  "iPhone5,2":  return "iPhone 5 (GSM+CDMA)"
        case "iPhone5,3":  return "iPhone 5c (GSM)"
        case "iPhone5,4":  return "iPhone 5c (GSM+CDMA)"
        case "iPhone6,1":  return "iPhone 5s (GSM)"
        case "iPhone6,2":  return "iPhone 5s (GSM+CDMA)"
        case "iPhone7,2":  return "iPhone 6"
        case "iPhone7,1":  return "iPhone 6 Plus"
        case "iPhone8,1":  return "iPhone 6s"
        case "iPhone8,2":  return "iPhone 6s Plus"
        case "iPhone8,4":  return "iPhone SE"
        case "iPhone9,1":   return "国行、日版、港行iPhone 7"
        case "iPhone9,2":  return "港行、国行iPhone 7 Plus"
        case "iPhone9,3":  return "美版、台版iPhone 7"
        case "iPhone9,4":  return "美版、台版iPhone 7 Plus"
        case "iPhone10,1","iPhone10,4":   return "iPhone 8"
        case "iPhone10,2","iPhone10,5":   return "iPhone 8 Plus"
        case "iPhone10,3","iPhone10,6":   return "iPhone X"
            
        case "iPad1,1":   return "iPad"
        case "iPad1,2":   return "iPad 3G"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":   return "iPad 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":  return "iPad Mini"
        case "iPad3,1", "iPad3,2", "iPad3,3":  return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":   return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":   return "iPad Air"
        case "iPad4,4", "iPad4,5", "iPad4,6":  return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":  return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":  return "iPad Mini 4"
        case "iPad5,3", "iPad5,4":   return "iPad Air 2"
        case "iPad6,3", "iPad6,4":  return "iPad Pro 9.7"
        case "iPad6,7", "iPad6,8":  return "iPad Pro 12.9"
        case "AppleTV2,1":  return "Apple TV 2"
        case "AppleTV3,1","AppleTV3,2":  return "Apple TV 3"
        case "AppleTV5,3":   return "Apple TV 4"
        case "i386", "x86_64":   return "Simulator"
        default:  return identifier
        }
    }
}
