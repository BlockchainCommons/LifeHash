//
//  Numerics.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation

typealias Frac = Double

extension BinaryFloatingPoint {
    /// Returns this value clamped to between 0.0 and 1.0
    public func clamped() -> Self {
        return max(min(self, 1.0), 0.0)
    }

    public func clamped(to r: ClosedRange<Self>) -> Self {
        return max(min(self, r.upperBound), r.lowerBound)
    }

    public func ledge() -> Bool {
        return self < 0.5
    }

    public func ledge<T>(_ a: @autoclosure () -> T, _ b: @autoclosure () -> T) -> T {
        return self.ledge() ? a() : b()
    }

    public var fractionalPart: Self {
        return self - rounded(.towardZero)
    }
}
