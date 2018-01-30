//
//  CrashMonitor.swift
//
//  Created by wangzhikui on 25/12/2017.
//

import Foundation
//代理需要实现的通讯协议
public protocol CrashMonitorDelegate: NSObjectProtocol {
    func crashMonitorDispatch(with model:CrashModel)
}

//weak化delegate对象对外暴露一个可扩展的数组，数组中存储weak代理
class WeakCrashMonitorDelegate: NSObject {
    weak var delegate: CrashMonitorDelegate?
    init(delegate: CrashMonitorDelegate) {
        super.init()
        self.delegate = delegate
    }
}

//在设置自己的exception handler先将原来设置的保存，再处理完之后再放回去，防止监控的app本身已经设置了
private var oldUncaughtExceptionHandler:(@convention(c) (NSException) -> Swift.Void)? = nil

public class CrashMonitor: NSObject {
    //crash监控是否打开
    public private(set) static var isStart: Bool = false
    //添加代理
    open class func addMonitorDelegate(delegate:CrashMonitorDelegate) {
        // 通过数组的筛选闭包函数filter 删选出所有不是nil的代理数组
        // 我们忽略了参数名而使用默认参数$0
        self.weekDelegates = self.weekDelegates.filter {
            return $0.delegate != nil
        }
        // 判断是否已经包含了要添加的代理
        let isContain = self.weekDelegates.contains {
            return $0.delegate?.hash == delegate.hash
        }
        // 如果不存在则将代理添加到数组中
        if isContain == false {
            let week = WeakCrashMonitorDelegate(delegate: delegate)
            self.weekDelegates.append(week)
        }
        // 如果代理数组包含数据则添加后自动开启监控
        if self.weekDelegates.count > 0 {
            self.startMonitor()
        }
    }
    //删除代理
    open class func removeMonitorDelegate(delegate:CrashMonitorDelegate) {
        //通过数组的filter函数
        self.weekDelegates = self.weekDelegates.filter {
            //将nil去掉
            return $0.delegate != nil
            }.filter {
                //获取需要删除的delegate之外的所有元素
                return $0.delegate?.hash != delegate.hash
        }
        //如果没有一个接收信息的delegate了则自动关闭监控
        if self.weekDelegates.count == 0 {
            self.stopMonitor()
        }
    }
    //开启监控
    private class func startMonitor() {
        guard self.isStart == false else {
            return
        }
        //设置启动标志位
        CrashMonitor.isStart = true
        //先获取系统设置的exception异常处理方法，防止我们写的方法覆盖了已有的
        oldUncaughtExceptionHandler = NSGetUncaughtExceptionHandler()
        //设置我们的exception异常处理方法
        NSSetUncaughtExceptionHandler(CrashMonitor.uncaughtExceptionHandler)
        //设置信号量异常处理方法
        self.setSignalExceptionHandler()
    }
    //停止监控
    private class func stopMonitor() {
        guard self.isStart == true else {
            return
        }
        //设置启动标志位
        CrashMonitor.isStart = false
        //停止监控将原来的异常处理方法设置回去
        NSSetUncaughtExceptionHandler(oldUncaughtExceptionHandler)
    }
    //注册不同信号量异常处理方法，这里只设置了几个经常出现的可以扩展
    private class func setSignalExceptionHandler(){
        signal(SIGABRT, CrashMonitor.signalExceptionHandler)
        signal(SIGILL, CrashMonitor.signalExceptionHandler)
        signal(SIGSEGV, CrashMonitor.signalExceptionHandler)
        signal(SIGFPE, CrashMonitor.signalExceptionHandler)
        signal(SIGBUS, CrashMonitor.signalExceptionHandler)
        signal(SIGPIPE, CrashMonitor.signalExceptionHandler)
//        for signal in CrashMonitor.monitorSignals {
//           signal(signal, CrashMonitor.signalExceptionHandler)
//        }
    }
    //uncaughtException的处理函数
    private static let uncaughtExceptionHandler: @convention(c) (NSException) -> Swift.Void = {
        (exteption) -> Void in
        //先调用已经设置的oldUncaughtExceptionHandler  处理再调用我们自己的处理方法
        if (oldUncaughtExceptionHandler != nil) {
            oldUncaughtExceptionHandler!(exteption);
        }
        guard CrashMonitor.isStart == true else {
            return
        }
        let reason = exteption.reason ?? "" //异常发生的原因
        let name = exteption.name //异常名称 NSExceptionName对象
        let threadName = Thread.current.yyyThreadName //发生异常的线程名
        let threadPriority = Thread.current.threadPriority //线程优先级
        let threadStatus = Thread.current.yyyThreadStatus //线程状态
        let model = CrashModel(type:"exception",
                               name:name.rawValue,
                               reason:reason,
                               callStack:"",
                               callStackArray:exteption.callStackSymbols,
                               threadName: threadName,
                               threadPriority: threadPriority,
                               threadStatus: threadStatus)
        //通知代理
        for delegate in CrashMonitor.weekDelegates {
            delegate.delegate?.crashMonitorDispatch(with: model)
        }
    }
    //信号量异常的处理函数
    private static let signalExceptionHandler : @convention(c) (Int32) -> Void = {
        (signal) -> Void in
        
        guard CrashMonitor.isStart == true else {
            return
        }
        var stack = Thread.callStackSymbols //堆栈堆栈
        let threadName = Thread.current.yyyThreadName //线程名
        let threadPriority = Thread.current.threadPriority //线程优先级
        let threadStatus = Thread.current.yyyThreadStatus //线程状态
        stack.removeFirst(2) //堆栈前两行是探针的信息所以删除
        let reason = transferSignalToHumanLanguage(of: signal)
        let model = CrashModel(type:"signal",
                               name:CrashMonitor.signalToString(of: signal),
                               reason:reason,
                               callStack:"",
                               callStackArray:stack,
                               threadName: threadName,
                               threadPriority: threadPriority,
                               threadStatus: threadStatus)
        //通知所有代理处理异常信息
        for delegate in CrashMonitor.weekDelegates {
            delegate.delegate?.crashMonitorDispatch(with: model)
        }
        //crash的时候由于设置了异常处理，系统认为我们处理了异常而不会关闭程序，所以这里要手动关掉一下
        CrashMonitor.killApp()
    }
    //将c返回的int32类型信号量转化为字符串
    private class func signalToString(of signal:Int32) -> String {
        switch (signal) {
        case SIGABRT:
            return "SIGABRT"
        case SIGILL:
            return "SIGILL"
        case SIGSEGV:
            return "SIGSEGV"
        case SIGFPE:
            return "SIGFPE"
        case SIGBUS:
            return "SIGBUS"
        case SIGPIPE:
            return "SIGPIPE"
        default:
            return "OTHER"
        }
    }
    //返回信号量产生的原因，不同的信号量都是由某一类原因造成，可以通过这里翻译为自然语言，这里只是简单返回了
    //一个string的串，可以根据自己的需要变更
    private class func transferSignalToHumanLanguage(of signal:Int32) -> String {
        switch (signal) {
        case SIGABRT:
            return "Signal SIGABRT(\(signal))."
        case SIGILL:
            return "Signal SIGILL(\(signal))."
        case SIGSEGV:
            return "Signal SIGSEGV(\(signal))."
        case SIGFPE:
            return "Signal SIGFPE(\(signal))."
        case SIGBUS:
            return "Signal SIGBUS(\(signal))."
        case SIGPIPE:
            return "Signal SIGPIPE(\(signal))."
        default:
            return "OTHER"
        }
    }
    
    //退出app
    private class func killApp(){
        NSSetUncaughtExceptionHandler(nil)
        signal(SIGABRT, SIG_DFL)
        signal(SIGILL, SIG_DFL)
        signal(SIGSEGV, SIG_DFL)
        signal(SIGFPE, SIG_DFL)
        signal(SIGBUS, SIG_DFL)
        signal(SIGPIPE, SIG_DFL)
        kill(getpid(), SIGKILL)
    }
    //week代理数组便于外部调用的时候添加多个delegate接收crash信息
    fileprivate static var weekDelegates = [WeakCrashMonitorDelegate]()
    //监控的信号量异常类型
    fileprivate static var monitorSignals:[Int32] = [SIGABRT,SIGILL,SIGSEGV,SIGFPE,SIGBUS,SIGPIPE]
}
