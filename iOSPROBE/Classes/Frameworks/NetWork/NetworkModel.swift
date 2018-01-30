//
//  NetworkModel.swift
//  iOSPROBE
//  网络请求数据的model类，由于数据比较多为了传递方便所以编写该类，并在该类的init中通过传入的request和response初始化需要的数据
//  Created by wangzhikui on 18/01/2018.
//  Copyright © 2018 wangzhikui. All rights reserved.
//

import Foundation

class NetworkModel: NSObject {
    
    /// Request
    @objc fileprivate(set) var requestURLString:String? //请求的url
    @objc fileprivate(set) var requestCachePolicy:String? //缓存方案
    @objc fileprivate(set) var requestTimeoutInterval:String? //超时时间
    @objc fileprivate(set) var requestHTTPMethod:String? //请求方法 post ,get
    @objc fileprivate(set) var requestAllHTTPHeaderFields:String? //请求头数据
    @objc fileprivate(set) var requestHTTPBody: String? //请求体数据
    
    /// Response
    @objc fileprivate(set) var responseMIMEType: String? //返回数据格式类型
    @objc fileprivate(set) var responseExpectedContentLength: Int64 = 0 //返回数据长度
    @objc fileprivate(set) var responseTextEncodingName: String? //返回数据编码
    @objc fileprivate(set) var responseSuggestedFilename:String? //
    @objc fileprivate(set) var responseStatusCode: Int = 200 //响应码
    @objc fileprivate(set) var responseAllHeaderFields: String? //返回所有头部信息
    @objc fileprivate(set) var receiveJSONData: String? //接收的数据
    
    /// 通过request和response 初始化model中的属性
    @objc init(request:URLRequest?, response: HTTPURLResponse?, data:Data?) {
        super.init()
        //request
        self.initRequest(request: request)
        //response
        self.initResponse(response: response, data: data)
    }

}

extension NetworkModel {
    
    fileprivate func initRequest(request:URLRequest?) {
        self.requestURLString = request?.url?.absoluteString
        self.requestCachePolicy = request?.cachePolicy.stringName()
        self.requestTimeoutInterval = request != nil ? String(request!.timeoutInterval) : "nil"
        self.requestHTTPMethod = request?.httpMethod
        
        if let allHTTPHeaderFields = request?.allHTTPHeaderFields {
            allHTTPHeaderFields.forEach({ [unowned self](e:(key: String, value: String)) in
                if self.requestAllHTTPHeaderFields == nil {
                    self.requestAllHTTPHeaderFields = "\(e.key):\(e.value)\n"
                }else {
                    self.requestAllHTTPHeaderFields!.append("\(e.key):\(e.value)\n")
                }
            })
        }
        
        if let bodyData = request?.httpBody {
            self.requestHTTPBody = String(data: bodyData, encoding: String.Encoding.utf8)
        }
    }

    fileprivate func initResponse(response: HTTPURLResponse?, data:Data?) {
        self.responseMIMEType = response?.mimeType
        self.responseExpectedContentLength = response?.expectedContentLength ?? 0
        self.responseTextEncodingName = response?.textEncodingName
        self.responseSuggestedFilename = response?.suggestedFilename
        self.responseStatusCode = response?.statusCode ?? 200
        
        response?.allHeaderFields.forEach { [unowned self] (e:(key: AnyHashable, value: Any)) in
            if self.responseAllHeaderFields == nil {
                self.responseAllHeaderFields = "\(e.key) : \(e.value)\n"
            }else {
                self.responseAllHeaderFields!.append("\(e.key) : \(e.value)\n")
            }
        }
        
        guard let data = data else {
            return
        }
        
        if self.responseMIMEType == "application/json" {
            self.receiveJSONData = self.getJSONSTringFromData(from: data)
        }else if self.responseMIMEType == "text/javascript" {
            
            //try to parse json if it is jsonp request
            if var jsonString = String(data: data, encoding: String.Encoding.utf8) {
                //formalize string
                if jsonString.hasSuffix(")") {
                    jsonString = "\(jsonString);"
                }
                
                if jsonString.hasSuffix(");") {
                    var range = (jsonString as NSString).range(of: "(")
                    if range.location != NSNotFound {
                        range.location += 1
                        range.length = (jsonString as NSString).length - range.location - 2  // removes parens and trailing semicolon
                        jsonString = (jsonString as NSString).substring(with: range)
                        let jsondata = jsonString.data(using: String.Encoding.utf8)
                        self.receiveJSONData = self.getJSONSTringFromData(from: jsondata)
                        
                    }
                }
            }
        }else if self.responseMIMEType == "application/xml" ||
            self.responseMIMEType == "text/xml" ||
            self.responseMIMEType == "text/plain" {
            let xmlString = String(data: data, encoding: String.Encoding.utf8)
            self.receiveJSONData = xmlString
        }else {
            self.receiveJSONData = "Untreated MimeType:\(String(describing: self.responseMIMEType))"
        }
    }
    //将data类型转换为json字符串
    private func getJSONSTringFromData(from data:Data?) -> String? {
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


