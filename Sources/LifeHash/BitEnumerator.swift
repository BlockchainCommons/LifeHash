//
//  BitEnumerator.swift
//  LifeHash
//
//  Created by Wolf McNally on 9/15/18.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import WolfCore

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
