//
//  DiskInfoTools.swift
//  iOSPROBE
//  获取磁盘空间
//  Created by wangzhikui on 30/12/2017.
//  Copyright © 2017 wangzhikui. All rights reserved.
//

import Foundation

class DiskInfoTools: NSObject {
    
    static let shared = DiskInfoTools()
    
    func getFreeDiskSpace() -> Int {
        do {
            let attributs = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            return attributs[FileAttributeKey.systemFreeSize] as! Int
        } catch {
            return 0
        }
    }
    
    func getTotalDiskSpace() -> Int {
        do {
            let attributs = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            return attributs[FileAttributeKey.systemSize] as! Int
        } catch {
            return 0
        }
    }
}
