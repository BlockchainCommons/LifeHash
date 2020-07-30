//
//  BitEnumerator.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 9/15/18.
//

import Foundation

final class BitEnumerator: Sequence, IteratorProtocol {
    private let data: Data
    private var byteIndex: Int
    private var bitMask: UInt8

    init(data: Data) {
        self.data = data
        byteIndex = 0
        bitMask = 0x80
    }

    func next() -> Bool? {
        guard byteIndex < data.count else { return nil }
        let result = (data[byteIndex] & bitMask) != 0
        bitMask >>= 1
        if bitMask == 0 {
            bitMask = 0x80
            byteIndex += 1
        }
        return result
    }

    func nextUInt2() -> UInt8? {
        var bitMask: UInt8 = 0x02
        var value: UInt8 = 0
        for _ in 0 ..< 2 {
            guard let b = next() else {
                return nil
            }
            if b {
                value |= bitMask
            }
            bitMask >>= 1
        }
        return value
    }

    func nextUInt8() -> UInt8? {
        var bitMask: UInt8 = 0x80
        var value: UInt8 = 0
        for _ in 0 ..< 8 {
            guard let b = next() else {
                return nil
            }
            if b {
                value |= bitMask
            }
            bitMask >>= 1
        }
        return value
    }

    func nextUInt16() -> UInt16? {
        var bitMask: UInt16 = 0x8000
        var value: UInt16 = 0
        for _ in 0 ..< 16 {
            guard let b = next() else {
                return nil
            }
            if b {
                value |= bitMask
            }
            bitMask >>= 1
        }
        return value
    }

    func nextFrac() -> Frac? {
        guard let i = nextUInt16() else {
            return nil
        }
        return Frac(i) / 65535.0
    }
}
