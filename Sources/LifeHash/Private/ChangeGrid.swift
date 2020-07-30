//
//  ChangeGrid.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 9/15/18.
//

import Foundation

class ChangeGrid: Grid<Bool> {
    init(size: IntSize) {
        super.init(size: size, initialValue: false)
    }

    func setChanged(_ g: IntPoint) {
        forNeighborhood(at: g) { (_, p) in
            self[p] = true
        }
    }

    override func stringRepresentation(of value: Bool) -> String {
        return value ? "🔴" : "🔵"
    }
}
