
//  Double+.swift
//  扩展Double类增加方法将数值转化为KB MB GB
//  Created by wangzhikui on 25/12/2017.
//

import Foundation

extension Double {
    func storageCapacity() -> (capacity:Double,unit:String) {

        let radix = 1000.0

        guard self > radix else {
            return (self,"B")
        }
        guard self > radix * radix else {
            return (self / radix,"KB")
        }
        
        guard self > radix * radix * radix else {
            return (self / (radix * radix),"MB")
        }

        return (self / (radix * radix * radix),"GB")
    }
}


