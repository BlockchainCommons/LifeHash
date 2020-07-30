//
//  PipeOperator.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation

infix operator |> : ForwardApplicationPrecedence
infix operator <| : BackwardApplicationPrecedence

precedencegroup ForwardApplicationPrecedence {
    associativity: left
    higherThan: BackwardApplicationPrecedence
}

precedencegroup BackwardApplicationPrecedence {
    associativity: right
    higherThan: ComparisonPrecedence
    lowerThan: NilCoalescingPrecedence
}

func |> <A, B>(lhs: A, rhs: (A) throws -> B) rethrows -> B {
    return try rhs(lhs)
}

@discardableResult func |> <A>(lhs: A, rhs: (A) throws -> Void) rethrows -> A {
    try rhs(lhs)
    return lhs
}

@discardableResult func <| <A, B>(lhs: (A) throws -> B, rhs: A) rethrows -> B {
    return try lhs(rhs)
}
