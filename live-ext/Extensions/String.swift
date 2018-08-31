//
//  String.swift
//  live-ext
//
//  Created by Jason Tsai on 2018/8/30.
//  Copyright © 2018年 io.ltebean. All rights reserved.
//

import Foundation

public extension String {
    static func random(_ length: Int = 4) -> String {
        let base = "abcdefghijklmnopqrstuvwxyz"
        var randomString: String = ""
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.characters.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
    
}
