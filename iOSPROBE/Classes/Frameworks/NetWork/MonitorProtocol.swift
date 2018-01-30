//
//  MonitorProtocol.swift
//  iOSPROBE
//  处理网络请求的类，将该类注册到URLProtocol和URLSession类的处理队列中即可
//  Created by 王智魁 on 18/01/2018.
//  Copyright © 2018 wangzhikui. All rights reserved.
//

import Foundation


class MonitorProtocol: URLProtocol {
    
    class func startMonitor() {
        URLProtocol.registerClass(self.classForCoder())
    }
    
    class func stopMonitor() {
        URLProtocol.unregisterClass(self.classForCoder())
    }
    
    open class func addMonitorDelegate(delegate:NetworkMonitorDelegate) {
        // 通过数组的筛选闭包函数filter 删选出所有不是nil的代理数组
        // 我们忽略了参数名而使用默认参数$0
        self.weekDelegates = self.weekDelegates.filter {
            return $0.delegate != nil
        }
        // 判断是否已经包含了要添加的代理
        let contains = self.weekDelegates.contains {
            return $0.delegate?.hash == delegate.hash
        }
        // 如果不存在则将代理添加到数组中
        if contains == false {
            let week = WeakNetworkMonitorDelegate(delegate: delegate)
            self.weekDelegates.append(week)
        }
    }
    
    open class func removeMonitorDelegate(delegate:NetworkMonitorDelegate) {
        //通过数组的filter函数
        self.weekDelegates = self.weekDelegates.filter {
            //将nil去掉
            return $0.delegate != nil
            }.filter {
                //获取需要删除的delegate之外的所有元素
                return $0.delegate?.hash != delegate.hash
        }
    }
    
    fileprivate var connection: NSURLConnection?
    fileprivate var startTsMS : Int? //开始时间戳，毫秒
    fileprivate var ca_request: URLRequest?
    fileprivate var ca_response: URLResponse?
    fileprivate var ca_data:Data?
    fileprivate static let ISDEAL = "isDeal" //是否已经处理的标志位
    private(set) static  var weekDelegates = [WeakNetworkMonitorDelegate]()
    
}

extension MonitorProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        guard let scheme = request.url?.scheme else {
            return false
        }
        //只处理http 和https的请求
        guard scheme == "http" || scheme == "https" else {
            return false
        }
        //判断该请求是否已经处理，已处理的则不需要重复处理
        guard URLProtocol.property(forKey: ISDEAL, in: request) == nil else {
            return false
        }
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        let req = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        //请求中设置一个属性标识该请求已经处理，防止死循环重复处理。因为拦截到请求之后会将请求继续下发，下发的请求系统再重新
        //走一遍看是否有拦截，此时还是会被我们自己要标识一下
        URLProtocol.setProperty(true, forKey: ISDEAL, in: req)
        //放入appid在头部
        req.addValue(BaseInfoTools.appid, forHTTPHeaderField: "appid")
        //放入业务id到request的头部，既要讲业务id发送到后台，也要讲业务id发给ios探针，这样将服务端采集的id与ios采集到的id对应起来
        req.addValue("MOBILE".appending(UUID().uuidString), forHTTPHeaderField: "busiid")
        return req.copy() as! URLRequest
    }
    
    override func startLoading() {
        let request = MonitorProtocol.canonicalRequest(for: self.request)
        self.connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        //开始发起请求的时候记录一个时间戳，结束的时候获取一个时间戳来计算整个请求的耗时
        self.startTsMS = BaseInfoTools.getTsMS()
        self.ca_request = self.request
    }
    
    override func stopLoading() {
        self.connection?.cancel()
        //计算本次请求的耗时
        let useTime = BaseInfoTools.getTsMS() - self.startTsMS!
        //通知所有代理
        for element in MonitorProtocol.weekDelegates {
            element.delegate?.networkMonitorDispatch(with: self.ca_request, response: self.ca_response, data: self.ca_data ,useTime: useTime)
        }
    }
}

extension MonitorProtocol: NSURLConnectionDelegate {
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        self.client?.urlProtocol(self, didFailWithError: error)
    }
    func connectionShouldUseCredentialStorage(_ connection: NSURLConnection) -> Bool {
        return true
    }
    func connection(_ connection: NSURLConnection, didReceive challenge: URLAuthenticationChallenge) {
        self.client?.urlProtocol(self, didReceive: challenge)
    }
    func connection(_ connection: NSURLConnection, didCancel challenge: URLAuthenticationChallenge) {
        self.client?.urlProtocol(self, didCancel: challenge)
    }
}

extension MonitorProtocol: NSURLConnectionDataDelegate {
    func connection(_ connection: NSURLConnection, willSend request: URLRequest, redirectResponse response: URLResponse?) -> URLRequest? {
        if response != nil {
            self.ca_response = response
            self.client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response!)
        }
        return request
    }
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.allowed)
        self.ca_response = response
    }
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
        if self.ca_data == nil {
            self.ca_data = data
        }else {
            self.ca_data!.append(data)
        }
    }
    func connection(_ connection: NSURLConnection, willCacheResponse cachedResponse: CachedURLResponse) -> CachedURLResponse? {
        return cachedResponse
    }
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        self.client?.urlProtocolDidFinishLoading(self)
    }
}
