//
//  IntRect.swift
//  LifeHash
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation

struct IntRect {
    var origin: IntPoint
    var size: IntSize

    init(origin: IntPoint = .zero, size: IntSize = .zero) {
        self.origin = origin
        self.size = size
    }

    var width: Int { return size.width }
    var height: Int { return size.height }

    var min: IntPoint { return origin }
    var max: IntPoint { return IntPoint(x: maxX, y: maxY) }
    var mid: IntPoint { return IntPoint(x: midX, y: midY) }

    var minX: Int { return origin.x }
    var minY: Int { return origin.y }

    var maxX: Int { return origin.x + size.width - 1 }
    var maxY: Int { return origin.y + size.height - 1 }

    var midX: Int { return origin.x + size.width / 2 }
    var midY: Int { return origin.y + size.height / 2 }

    var rangeX: CountableClosedRange<Int> { return minX ... maxX }
    var rangeY: CountableClosedRange<Int> { return minY ... maxY }

    func randomX() -> Int { return origin.x + size.randomX() }
    func randomY() -> Int { return origin.y + size.randomY() }
    func randomPoint() -> IntPoint { return IntPoint(x: randomX(), y: randomY()) }

    func isValidPoint(_ p: IntPoint) -> Bool {
        return p.x >= minX && p.y >= minY && p.x <= maxX && p.y <= maxY
    }

    func checkPoint(_ point: IntPoint) {
        assert(point.x >= minX, "x must be >= \(minX)")
        assert(point.y >= minY, "y must be >= \(minY)")
        assert(point.x <= maxX, "x must be <= \(maxX)")
        assert(point.y <= maxY, "y must be <= \(maxY)")
    }
}

extension IntRect: CustomStringConvertible {
    var description: String {
        return("IntRect(\(origin), \(size))")
    }
}

extension IntRect {
    static let zero = IntRect()
}

extension IntRect: Equatable {
    static func == (lhs: IntRect, rhs: IntRect) -> Bool {
        return lhs.origin == rhs.origin && lhs.size == rhs.size
    }
}

extension IntRect: Codable {
}
