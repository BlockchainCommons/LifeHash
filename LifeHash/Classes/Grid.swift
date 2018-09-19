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

import WolfGeometry
import WolfFoundation

public class Grid<T: Equatable>: Equatable {
    public let size: IntSize
    public var maxX: Int { return size.width - 1 }
    public var maxY: Int { return size.height - 1 }
    private(set) var rows: [[T]]

    public init(size: IntSize, initialValue: T) {
        self.size = size
        let row = [T](repeating: initialValue, count: size.width)
        rows = [[T]](repeating: row, count: size.height)
    }

    public func isValid(coordinate point: IntPoint) -> Bool {
        guard point.x >= 0 else { return false }
        guard point.y >= 0 else { return false }
        guard point.x < size.width else { return false }
        guard point.y < size.height else { return false }
        return true
    }

    public func checkValid(coordinate coord: IntPoint) throws {
        guard isValid(coordinate: coord) else { throw LifeHashError("Invalid coordinate: \(coord)") }
    }

    public func getValue(atCoordinate coord: IntPoint) throws -> T {
        try checkValid(coordinate: coord)
        return rows[coord.y][coord.x]
    }

    public func setValue(_ value: T, atCoordinate point: IntPoint) throws {
        try checkValid(coordinate: point)
        rows[point.y][point.x] = value
    }

    public func getValue(atCircularCoordinate coord: IntPoint) -> T {
        let cx = makeCircularIndex(at: coord.y, count: size.height)
        let cy = makeCircularIndex(at: coord.x, count: size.width)
        return try! getValue(atCoordinate: IntPoint(x: cx, y: cy))
    }

    public func setValue(_ value: T, atCircularCoordinate coord: IntPoint) {
        let cx = makeCircularIndex(at: coord.y, count: size.height)
        let cy = makeCircularIndex(at: coord.x, count: size.width)
        try! setValue(value, atCoordinate: IntPoint(x: cx, y: cy))
    }

    public func forAll(_ f: (IntPoint) -> Void) {
        for y in 0..<size.height {
            for x in 0..<size.width {
                f(IntPoint(x: x, y: y))
            }
        }
    }

    public func setAll(_ value: T) {
        forAll { p in
            self[p] = value
        }
    }

    public func forNeighborhood(at point: IntPoint, f: (_ o: IntPoint, _ p: IntPoint) -> Void) {
        for oy in -1 ... 1 {
            for ox in -1 ... 1 {
                let o = IntPoint(x: ox, y: oy)
                let p = IntPoint(x: makeCircularIndex(at: ox + point.x, count: size.width), y: makeCircularIndex(at: oy + point.y, count: size.height))
                f(o, p)
            }
        }
    }

    public subscript(point: IntPoint) -> T {
        get { return try! self.getValue(atCoordinate: point) }
        set { try! self.setValue(newValue, atCoordinate: point) }
    }

    public subscript(x: Int, y: Int) -> T {
        get { return self[IntPoint(x: x, y: y)] }
        set { self[IntPoint(x: x, y: y)] = newValue }
    }

    public func equals(_ g: Grid<T>) -> Bool {
        guard size == g.size else { return false }
        return true
    }

    public func stringRepresentation(of value: T) -> String {
        return "\(value)"
    }

    public var stringRepresentation: String {
        return rows.map { $0.map { return "\(stringRepresentation(of: $0))" }.joined(separator: " ") }.joined(separator: "\n")
    }

    public func dump() {
        print(stringRepresentation)
    }
}

public func == <T>(lhs: Grid<T>, rhs: Grid<T>) -> Bool {
    return lhs.equals(rhs)
}
