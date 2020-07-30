//
//  BitAggregator.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 9/16/18.
//

import Foundation

struct BitAggregator {
    var data: Data
    private var bitMask: UInt8

    init() {
        data = Data(count: 0)
        bitMask = 0
    }

    mutating func append(bit: Bool) {
        if bitMask == 0 {
            bitMask = 0x80
            data.append(0)
        }
        if bit {
            data[data.count - 1] = data[data.count - 1] | bitMask
        }
        bitMask >>= 1
    }
}
