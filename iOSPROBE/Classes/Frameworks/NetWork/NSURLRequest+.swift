//
//  NSURLRequest+.swift
//  iOSPROBE
//
//  Created by 王智魁 on 18/01/2018.
//  Copyright © 2018 wangzhikui. All rights reserved.
//

import Foundation

///增加stringName 将int类型的枚举转换为字符串
extension NSURLRequest.CachePolicy {
    
    func stringName() -> String {
        
        switch self {
        case .useProtocolCachePolicy:
            return ".useProtocolCachePolicy"
        case .reloadIgnoringLocalCacheData:
            return ".reloadIgnoringLocalCacheData"
        case .reloadIgnoringLocalAndRemoteCacheData:
            return ".reloadIgnoringLocalAndRemoteCacheData"
        case .returnCacheDataElseLoad:
            return ".returnCacheDataElseLoad"
        case .returnCacheDataDontLoad:
            return ".returnCacheDataDontLoad"
        case .reloadRevalidatingCacheData:
            return ".reloadRevalidatingCacheData"
        }
        
    }
}
