//
//  IntSize.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation

struct IntSize {
    var width: Int
    var height: Int

    init(width: Int = 0, height: Int = 0) {
        self.width = width
        self.height = height
    }

    func randomX() -> Int {
        return Int.random(in: 0 ..< width)
    }

    func randomY() -> Int {
        return Int.random(in: 0 ..< height)
    }
//
//    func randomPoint() -> Point {
//        return Point(x: randomX(), y: randomY())
//    }

    static let zero = IntSize()

    var bounds: IntRect {
        return IntRect(origin: .zero, size: self)
    }

//   var aspect: CGFloat {
//        return CGFloat(width) / CGFloat(height)
//    }
}

extension IntSize: CustomStringConvertible {
    var description: String {
        get {
            return "IntSize(width:\(width) height:\(height))"
        }
    }
}

extension IntSize: Equatable {
    static func == (lhs: IntSize, rhs: IntSize) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height
    }
}

extension IntSize: Codable {
}
