//
//  DModel.swift
//  iOSPROBE_EXAMPLE
//
//  Created by 王智魁 on 28/12/2017.
//  Copyright © 2017 友云音. All rights reserved.
//


import Foundation

class DemoModel: NSObject {
    
    @objc private(set) var title: String!
    
    @objc private(set) var action: (()->())!
    
    @objc init(title:String,action:@escaping ()->()) {
        super.init()
        self.title = title
        self.action = action
    }
}

class DemoSection: NSObject {
    @objc private(set) var header: String!
    @objc private(set) var model:[DemoModel]!
    
    @objc init(header:String,model:[DemoModel]) {
        super.init()
        self.header = header
        self.model = model
    }
}

class DemoModelFactory: NSObject {
    
    @objc static var crashSection: DemoSection {
        var models = [DemoModel]()
        var model = DemoModel(title: "异常 造成崩溃") {
            let array = NSArray()
            _ = array[2]
        }
        models.append(model)
        
        model = DemoModel(title: "信号量 造成崩溃") {
            var a = [String]()
            _ = a[2]
        }
        models.append(model)
        
        return DemoSection(header: "崩溃", model: models)
    }
    
    @objc static var networkSection: DemoSection {
        let url = URL(string: "https://api.github.com/search/users?q=language:objective-c&sort=followers&order=desc")
        //        let url = URL(string: "http:/ycm.yonyou.com/api/busi/keybusilist/query")
        let request = URLRequest(url: url!)
        
        var new = [DemoModel]()
        
        var title = "发送同步请求"
        var model = DemoModel(title: title) {
            _ = try! NSURLConnection.sendSynchronousRequest(request, returning: nil)
            alert(t: "完成", "NSURLConnection方式发送同步请求")
          
        }
        new.append(model)
        
        title = "发送异步请求"
        model = DemoModel(title: title) {
            NSURLConnection.sendAsynchronousRequest(request,
                                                    queue: OperationQueue.main,
                                                    completionHandler: {(response, data, error) in
                                                        alert(t: "完成", "NSURLConnection方式发送异步请求")
                                                        print("发送异步请求返回的结果：")
                                                        print(data as Any)
                                                     
            })
        }
        new.append(model)
        
        title = "URLSession方式发送"
        model = DemoModel(title: title) {
            let session = URLSession.shared
            URLSession.shared.dataTask(with: request)
            let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
                alert(t: "完成", "URLSession方式发送")
            }
            task.resume()
        }
        new.append(model)
        
        title = "URLSessionConfiguration方式发送"
        model = DemoModel(title: title) {
            let configure = URLSessionConfiguration.default
            let session = URLSession(configuration: configure,
                                     delegate: nil,
                                     delegateQueue: OperationQueue.current)
            let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
                alert(t: "完成", "URLSessionConfiguration方式发送")
            }
            task.resume()
        }
        new.append(model)
        
        return DemoSection(header: "网络", model: new)
    }
    
    //    @objc static var aslSection: DemoSection {
    //        var models = [DemoModel]()
    //        let model = DemoModel(title: "日志") {
    //            NSLog("测试日志输出")
    //        }
    //        //models.append(model)
    //
    //        return DemoSection(header: "日志", model: models)
    //    }
    
    @objc static var anrSection: DemoSection {
        var models = [DemoModel]()
        
        let title = "ANR（请求无响应）"
        let model = DemoModel(title: title) {
            sleep(4)
            alert(t: "完成", title)
        }
        models.append(model)
        
        return DemoSection(header: "ANR", model: models)
    }
    
}
