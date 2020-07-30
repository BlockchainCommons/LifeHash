//
//  CellGrid.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 9/15/18.
//

import Foundation

class CellGrid: Grid<Bool> {
    init(size: IntSize) {
        super.init(size: size, initialValue: false)
    }

    var data: Data {
        set {
            let bits = BitEnumerator(data: newValue)
            forAll { point in
                let alive = bits.next() ?? false
                setValue(alive, atCoordinate: point)
            }
        }

        get {
            var bitAggregator = BitAggregator()
            forAll { point in
                bitAggregator.append(bit: getValue(atCoordinate: point))
            }
            return bitAggregator.data
        }
    }

    private func countNeighbors(_ g: IntPoint) -> Int {
        var count = 0
        forNeighborhood(at: g) { (o, p) in
            guard o != .zero else { return }
            if self[p] {
                count += 1
            }
        }
        return count
    }

    private static func isAliveInNextGeneration(_ currentAlive: Bool, neighborsCount: Int) -> Bool {
        if currentAlive {
            return neighborsCount == 2 || neighborsCount == 3
        } else {
            return neighborsCount == 3
        }
    }

    func nextGeneration(currentChangeGrid: ChangeGrid, nextCellGrid: CellGrid, nextChangeGrid: ChangeGrid) {
        nextCellGrid.setAll(false)
        nextChangeGrid.setAll(false)
        forAll { p in
            let currentAlive = self[p]
            if currentChangeGrid[p] {
                let neighborsCount = self.countNeighbors(p)
                let nextAlive = CellGrid.isAliveInNextGeneration(currentAlive, neighborsCount: neighborsCount)
                if nextAlive {
                    nextCellGrid[p] = true
                }
                if currentAlive != nextAlive {
                    nextChangeGrid.setChanged(p)
                }
            } else {
                nextCellGrid[p] = currentAlive
            }
        }
    }

    override func stringRepresentation(of value: Bool) -> String {
        return value ? "⚪️" : "⚫️"
    }
}
