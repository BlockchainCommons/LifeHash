//
//  CellGrid.swift
//  LifeHash
//
//  Created by Wolf McNally on 9/15/18.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import WolfGeometry

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
            if currentChangeGrid[p] {
                let currentAlive = self[p]
                let neighborsCount = self.countNeighbors(p)
                let nextAlive = CellGrid.isAliveInNextGeneration(currentAlive, neighborsCount: neighborsCount)
                if nextAlive {
                    nextCellGrid[p] = true
                }
                if currentAlive != nextAlive {
                    nextChangeGrid.setChanged(p)
                }
            }
        }
    }

    override func stringRepresentation(of value: Bool) -> String {
        return value ? "⚪️" : "⚫️"
    }
}
