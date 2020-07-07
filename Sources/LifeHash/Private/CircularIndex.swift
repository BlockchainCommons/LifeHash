//
//  CircularIndex.swift
//  LifeHash
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation

@inlinable func makeCircularIndex(at index: Int, count: Int) -> Int {
    guard count > 0 else { return 0 }
    let i = index % count
    return i >= 0 ? i : i + count
}

extension Collection {
    @inlinable func circularIndex(at index: Int) -> Index {
        return self.index(startIndex, offsetBy: makeCircularIndex(at: index, count: count))
    }

    @inlinable func element(atCircularIndex index: Int) -> Element {
        return self[circularIndex(at: index)]
    }
}

extension MutableCollection {
    @inlinable mutating func replaceElement(atCircularIndex index: Int, withElement element: Element) {
        self[circularIndex(at: index)] = element
    }
}
