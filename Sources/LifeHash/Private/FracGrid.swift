//
//  FracGrid.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 9/15/18.
//

import Foundation

class FracGrid: Grid<Frac> {
    init(size: IntSize) {
        super.init(size: size, initialValue: 0)
    }

    func overlay(cellGrid: CellGrid, frac: Frac) {
        forAll { p in
            if cellGrid[p] {
                self[p] = frac
            }
        }
    }

    override func stringRepresentation(of value: Frac) -> String {
        "\(value)"
    }
}
