//
//  Color.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation

struct Color {
    let r: UInt8
    let g: UInt8
    let b: UInt8

    @inlinable init(r: UInt8, g: UInt8, b: UInt8) {
        self.r = r
        self.g = g
        self.b = b
    }
}
