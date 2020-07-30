//
//  IntPoint.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation

struct IntPoint {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    static let zero = IntPoint(x: 0, y: 0)
}

//extension IntPoint {
//    var point: Point {
//        return Point(x: Double(x), y: Double(y))
//    }
//}

//func + (lhs: IntPoint, rhs: IntOffset) -> IntPoint {
//    return IntPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
//}

//func += (lhs: inout IntPoint, rhs: IntOffset) {
//    lhs = lhs + rhs
//}

extension IntPoint: CustomStringConvertible {
    var description: String {
        get {
            return "IntPoint(x:\(x) y:\(y))"
        }
    }
}

extension IntPoint: Equatable {
    static func == (lhs: IntPoint, rhs: IntPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension IntPoint: Codable {
}
