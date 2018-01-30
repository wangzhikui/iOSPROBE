# IOS探针

## 使用方法

### 一、下载压缩包后解压
### 二、将压缩包内的iOSPROBE.framework引入工程中
### 三、在App入口代码处引入包并加入如下代码（tid和appid可在下载页面上查看）
Swift:
```swift
 YYY.openMonitor(tid:"填入实际的tid",appid:"填入实际的appid")
```
OC
```swift
 [YYY openMonitorWithTid:@"填入实际的tid" appid:@"填入实际的appid"];
```
### 四、特别说明探针有获取位置的功能，建议app开启此功能。如不开启不影响功能正常使用，但会影响获取用户位置的准确度

swift完整示例：   
```swift 
import UIKit
import iOSPROBE

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        YYY.openMonitor(tid:"FtxuKMUUYm7901013387",appid:"isYGhdQJgf0539424036&")
        return true
    }
}
```
OC完整示例：   
```swift 
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "iOSPROBE/iOSPROBE-Swift.h"
int main(int argc, char * argv[]) {
    [YYY openMonitorWithTid:@"FtxuKMUUYm7901010000" appid:@"isYGhdQJgf05394240000"];
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
```
### 五、使用Objective-C开发的应用，因为本探针使用swift开发，所以需要将下面设置打开
<img src="./README/image/ocset.png"  width="100%"/>

## 自行编译sdk
项目包含一个示例项目iOSPROBER_EXAMPLE，可使用该示例程序运行该工程  
    
下载项目到本地，使用Xode打开iOSPROBE.xcodeproj即可  
```git
git clone git@git.yonyou.com:wangzhk/iOSPROBE.git
```

开发环境  
```
Xode 9.1
Development target 10.0
swift language 3.2
部分OC混编
```
EXAMPLE的调试环境
```
模拟器 ios11.1
真机 iphone 6s  ios 10.3.3
```

swift+OC混编 桥接需要将三个oc的头文件添加到heads中如图：  
  
<img src="./README/image/headfile.png" width="100%"/>


## 附接口格式
    
**[探针发送云端接口格式](./README/INTERFACE.md)**  
  
      
**[能采集的主要数据字段说明](./README/METADATA.md)** 
