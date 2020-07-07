//
//  Grid.swift
//  WolfCore
//
//  Created by Wolf McNally on 1/20/16.
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

class Grid<T: Equatable>: Equatable {
    let size: IntSize
    let maxX: Int
    let maxY: Int
    let capacity: Int
    let storage: UnsafeMutablePointer<T>

    init(size: IntSize, initialValue: T) {
        self.size = size
        maxX = size.width - 1
        maxY = size.height - 1
        capacity = size.width * size.height
        storage = UnsafeMutablePointer<T>.allocate(capacity: capacity)
        storage.initialize(repeating: initialValue, count: capacity)
    }

    deinit {
        storage.deallocate()
    }

    func isValid(coordinate point: IntPoint) -> Bool {
        guard point.x >= 0 else { return false }
        guard point.y >= 0 else { return false }
        guard point.x < size.width else { return false }
        guard point.y < size.height else { return false }
        return true
    }

    @usableFromInline func offset(for coord: IntPoint) -> Int {
        let o = coord.y * size.width + coord.x
        guard o < capacity else { fatalError() }
        return o
    }

    @inlinable func getValue(atCoordinate coord: IntPoint) -> T {
        return storage[offset(for: coord)]
    }

    @inlinable func setValue(_ value: T, atCoordinate coord: IntPoint) {
        storage[offset(for: coord)] = value
    }

    @inlinable func getValue(atCircularCoordinate coord: IntPoint) -> T {
        let cx = makeCircularIndex(at: coord.y, count: size.height)
        let cy = makeCircularIndex(at: coord.x, count: size.width)
        return getValue(atCoordinate: IntPoint(x: cx, y: cy))
    }

    @inlinable func setValue(_ value: T, atCircularCoordinate coord: IntPoint) {
        let cx = makeCircularIndex(at: coord.y, count: size.height)
        let cy = makeCircularIndex(at: coord.x, count: size.width)
        setValue(value, atCoordinate: IntPoint(x: cx, y: cy))
    }

    @inlinable func forAll(_ f: (IntPoint) -> Void) {
        for y in 0..<size.height {
            for x in 0..<size.width {
                f(IntPoint(x: x, y: y))
            }
        }
    }

    @inlinable func setAll(_ value: T) {
        forAll { p in
            self[p] = value
        }
    }

    @inlinable func forNeighborhood(at point: IntPoint, f: (_ o: IntPoint, _ p: IntPoint) -> Void) {
        for oy in -1 ... 1 {
            for ox in -1 ... 1 {
                let o = IntPoint(x: ox, y: oy)
                let p = IntPoint(x: makeCircularIndex(at: ox + point.x, count: size.width), y: makeCircularIndex(at: oy + point.y, count: size.height))
                f(o, p)
            }
        }
    }

    @inlinable subscript(point: IntPoint) -> T {
        get { return self.getValue(atCoordinate: point) }
        set { self.setValue(newValue, atCoordinate: point) }
    }

    @inlinable subscript(x: Int, y: Int) -> T {
        get { return self[IntPoint(x: x, y: y)] }
        set { self[IntPoint(x: x, y: y)] = newValue }
    }

    @inlinable func equals(_ g: Grid<T>) -> Bool {
        guard size == g.size else { return false }
        return true
    }

    func stringRepresentation(of value: T) -> String {
        return "\(value)"
    }

    var stringRepresentation: String {
        var result = ""

        for y in 0..<size.height {
            for x in 0..<size.width {
                let p = IntPoint(x: x, y: y)
                let value = self[p]
                result.append(stringRepresentation(of: value))
                if x != maxX {
                    result.append(" ")
                }
            }
            if y != maxY {
                result.append("\n")
            }
        }

        return result
    }

    func dump() {
        print(stringRepresentation)
    }
}

func == <T>(lhs: Grid<T>, rhs: Grid<T>) -> Bool {
    return lhs.equals(rhs)
}
