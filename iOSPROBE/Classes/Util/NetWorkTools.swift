//
//  NetWorkTools.swift
//  发送网络请求的工具类
//  Created by wangzhikui on 19/12/2017.
//

import Foundation

class NetworkTools {
    //在探针初始化的时候设置这两个地址，目前是在YYY.swift中设置
    //发送云端的主机ip，在监控的所有net请求中要把发送到该地址的请求过滤掉
    public static var host = ""
    //发送云端的地址
    public static var url = ""
    ///paramStr 参数 json格式[{"",""}]
    class func post(url:String,jsonStr : String){
        let url = URL(string: url)
        var request = URLRequest(url: url!)
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        //给请求头设置tid
        request.addValue(BaseInfoTools.tid, forHTTPHeaderField: "tid")
        request.httpBody = jsonStr.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        //初始化请求
        let dataTask = session.dataTask(with: request,completionHandler: { (data, resp, err) in
            if err != nil {
                //请求云端异常暂不做任何处理
            } else {
                //---自己调试使用
                let responseStr = String(data: data!,encoding: String.Encoding.utf8)
                print(responseStr!)
                let dic = BaseInfoTools.getDictionaryFromJSONData(jsonData: data!)
                //走到云端返回的格式+走到网关就被拒绝返回的格式
//                {"msg":"ok","failed":0,"status":200,"successed":1}
//                {"errordetailmsg": "","errormsg": "license校验失败","statuscode": "1001"}
                if dic.value(forKey: "statuscode") != nil{
                    let code : String = dic.value(forKey: "statuscode") as! String
                    //发送请求成功判断返回结果是否停止采集，在某种情况下云端返回一个标识码，让App探针停止采集
                    if "1001" == code{
                        BaseInfoTools.stopMonitor()
                    }
                }
            }
        }) as URLSessionTask
        dataTask.resume()   //执行任务
    }
    //通用的发送逻辑，云端接口是一个，在json中通过pt来区分发送的是什么数据
    class func postCommon(jsonStr:String){
        print("上传数据到云端json")
        print(jsonStr)
        self.post(url: url, jsonStr: jsonStr)
    }

}
