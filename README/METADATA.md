# 能采集到的数据主要字段
## ANR-请求无响应
```
当前线程号：threshold: Double!            
主线程堆栈：mainThreadBacktrace:String?
所有线程堆栈：allThreadBacktrace:String?
应用名称：displayName
应用版本：appVersion
系统版本：iosVersion
设备唯一标识：identifierNumber //设备唯一标识
手机具体型号名称：modelName //手机具体型号名称 iphone 6s
总容量：totalSpace  //总容量 byte
可用容量：freeSpace  //可用容量 byte
总内存：totalMemory  //总内存  byte
可用内存：freeMemory  //可用内存 byte
```
## crash-崩溃
```
造成崩溃的类型：（exception或signal）type: CrashModelType!
name: String!
原因：reason: String!
app信息：appinfo: String!
堆栈：callStackArray: [String]!
记录的id：uuid = UUID().uuidString  //记录的id ???
包：bundleIdentifier
版本标识：build   //xcode设置项目的build  内部版本标识
应用名称：displayName
应用版本：appVersion
设备唯一标识：deviceid
ip：hostip // 连接wifi就获取wifi，wan就获取手机
省份：province //省份
城市：city /城市
存储剩余容量：root //获取本地硬盘剩余容量 byte
手机型号： //手机具体型号名称 iphone 6s
内存使用率：memory //内存使用率
连网方式：netsts //wifi还是非wifi
系统版本：osver //系统版本
```
## NetWork-网络监控
```
/// Request
请求url：requestURLString:String?
请求缓存策略：requestCachePolicy:String?
请求超时时间：requestTimeoutInterval:String?
请求的类型post或get：requestHTTPMethod:String?
请求头信息：requestAllHTTPHeaderFields:String?
请求体信息：requestHTTPBody: String?
/// Response
接收返回的类型：responseMIMEType: String?
接收数据长度：responseExpectedContentLength: Int64 = 0
接收数据的编码名称：responseTextEncodingName: String?
发送的请求的action名称：responseSuggestedFilename:String?
请求状态码：responseStatusCode: Int = 200
返回头信息responseAllHeaderFields: String?
返回数据json：receiveJSONData: String?
//计算发送数据的长度 带的request里边没有直接的长度信息，这里计算headfield+httpbody+url的长度 有的数据是直接包含在url里边，所以这里计算一下url长度
发送数据长度：bytesent  //发送数据长度 ???
设备唯一标识：deviceid //设备唯一标识
请求方式：model //post or get
状态码：status //状态码
总耗时：total //总耗时
请求的url：url //请求的url地址
联网方式：wan  //wifi或非wifi
网络服务提供商：carrier//网络服务提供商
```
## system
```
帧率：FPS
应用cpu使用率：app cpu
应用内存使用率：app ram
系统cpu使用率：sys cpu 
系统内存使用率：sys ram

```
## 设备信息
```
ios版本：iosVersion //iOS版本 10.0
设备唯一标识：identifierNumber //设备udid
系统名称：systemName //系统名称 ios
设备型号：model //设备型号  iphone
设备具体型号：modelName  //设备具体型号 iphone 6s CDMA
设备区域号型号：localizedModel  //设备区域化型号如A1533
```
## 应用信息
```
app名称：infoDictionary["CFBundleDisplayName”]
app版本号：infoDictionary["CFBundleShortVersionString”]
版本号 内部标号：infoDictionary["CFBundleVersion”]
```