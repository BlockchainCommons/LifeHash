//
//  Interval.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation

///
/// Interval-Creation Operator
///
infix operator .. : RangeFormationPrecedence

/// Operator to create a closed floating-point interval. The first number may
/// be greater than the second. Examples:
///
///     let i = 0..100
///     let j = 100..3.14
///
/// - Parameter left: The first bound. May be greater than the second bound
/// - Parameter right: The second bound.
func .. <T>(left: T, right: T) -> Interval<T> {
    return Interval(left, right)
}

/// Represents a closed floating-point interval from `a`..`b`. Unlike ClosedRange,
/// `a` may be greater than `b`.
struct Interval<T: BinaryFloatingPoint> {
    typealias Bound = T

    let a: Bound
    let b: Bound

    /// Creates a closed interval from `a`..`b`. `a` may be greater than `b`.
    init(_ a: Bound, _ b: Bound) {
        self.a = a
        self.b = b
    }

    static var unit: Interval<T> { return 0 .. 1 }
}

extension Interval {
    var extent: T {
        return b - a
    }
}

extension Interval {
    /// Returns `true` if `a` is less than `b`, and `false` otherwise.
    var isAscending: Bool {
        return a < b
    }

    /// Returns `true` if `a` is greater than `b`, and `false` otherwise.
    var isDescending: Bool {
        return a > b
    }

    /// Returns `true` if `a` is equal to `b`, and `false` otherwise.
    var isFlat: Bool {
        return a == b
    }
}

extension Interval {
    /// Returns an interval with the same bounds as this interval, but swapped
    func swapped() -> Interval {
        return Interval(b, a)
    }

    /// Returns an interval with the same bounds as this interval, but where `a` is the minimum bound and `b` is the maximum bound.
    func normalized() -> Interval {
        return isAscending ? self : swapped()
    }
}

extension Interval {
    /// Returns the lesser of the two bounds
    var min: Bound {
        return Swift.min(a, b)
    }

    /// Returns the greater of the two bounds
    var max: Bound {
        return Swift.max(a, b)
    }

    /// Returns `true` if the interval contains the value `n`, otherwise returns `false`.
    func contains(_ n: Bound) -> Bool {
        return min <= n && n <= max
    }

    /// Returns `true` if the interval fully contains the `other` interval.
    func contains(_ other: Interval) -> Bool {
        return min <= other.min && other.max <= max
    }

    /// Returns `true` if the interval intersects with the `other` interval.
    func intersects(with other: Interval) -> Bool {
        return contains(other.a) || contains(other.b)
    }

    /// Returns the interval that is the intersection of this interval with the `other` interval.
    /// If the intervals do not intersect, return `nil`.
    func intersection(with other: Interval) -> Interval? {
        guard intersects(with: other) else { return nil }
        return Interval(Swift.max(min, other.min), Swift.min(max, other.max))
    }

    /// Returns an interval with `a` being the least bound of the two intervals,
    /// and `b` being the greatest bound of the two intervals.
    func extent(with other: Interval) -> Interval {
        return Interval(Swift.min(min, other.min), Swift.max(max, other.max))
    }
}

extension Interval: CustomStringConvertible {
    var description: String {
        return "Interval(\(a) .. \(b))"
    }
}

extension Interval {
    /// Converts a `ClosedRange` to an Interval.
    init(_ i: ClosedRange<Bound>) {
        self.a = i.lowerBound
        self.b = i.upperBound
    }

    /// Converts this `Interval` to a `ClosedRange`. If `a` > `b` then `b`
    /// will be the range's `lowerBound`.
    var closedRange: ClosedRange<Bound> {
        let i = normalized()
        return i.a ... i.b
    }
}

extension Interval: Equatable {
}

extension Double {
    static let unit = Interval<Double>(0, 1)
}

extension Float {
    static let unit = Interval<Float>(0, 1)
}

#if canImport(CoreGraphics)
    import CoreGraphics

    extension CGFloat {
        static let unit = Interval<CGFloat>(0, 1)
    }
#endif
