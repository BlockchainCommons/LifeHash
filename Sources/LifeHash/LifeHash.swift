//
//  LifeHash.swift
//  WolfCore
//
//  Created by Wolf McNally on 1/20/16.
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

import WolfColor
import WolfCore
import WolfGeometry
import WolfImage

public struct LifeHash {
    private typealias `Self` = LifeHash
    private static let defaultSize = IntSize(width: 16, height: 16)
    private static let defaultMaxGenerations = 150

    public let size: IntSize
    let fracGrid: FracGrid
    let generations: Int
    let colorGrid: ColorGrid

    public init(data: Data) {
        self.init(data: data, size: Self.defaultSize, maxGenerations: Self.defaultMaxGenerations)
    }

    public init(string: String) {
        let data = string.data(using: .utf8)!
        self.init(data: data, size: Self.defaultSize, maxGenerations: Self.defaultMaxGenerations)
    }

    init(data: Data, size: IntSize, maxGenerations: Int) {
        let shaDigest = data |> sha256
        self.size = size

        var currentCellGrid = CellGrid(size: size)
        var nextCellGrid = CellGrid(size: size)

        var currentChangeGrid = ChangeGrid(size: size)
        var nextChangeGrid = ChangeGrid(size: size)

        var historySet = Set<Data>()
        var history = [Data]()

        nextCellGrid.data = shaDigest
        nextChangeGrid.setAll(true)

        while history.count < maxGenerations {
            swap(&currentCellGrid, &nextCellGrid)
            swap(&currentChangeGrid, &nextChangeGrid)

            let data = currentCellGrid.data
            guard !historySet.contains(data) else {
                break
            }
            historySet.insert(data)
            history.append(data)

            currentCellGrid.nextGeneration(currentChangeGrid: currentChangeGrid, nextCellGrid: nextCellGrid, nextChangeGrid: nextChangeGrid)
        }

        fracGrid = FracGrid(size: size)
        for (index, data) in history.enumerated() {
            currentCellGrid.data = data
            let frac: Frac
            frac = Double(index + 1).lerpedToFrac(from: 0 .. Double(history.count)).clamped()
            fracGrid.overlay(cellGrid: currentCellGrid, frac: frac)
        }

        generations = history.count

        let entropy = BitEnumerator(data: shaDigest)
        let gradient = selectGradient(entropy: entropy)
        let pattern = selectPattern(entropy: entropy)
        colorGrid = ColorGrid(fracGrid: fracGrid, gradient: gradient, pattern: pattern)
    }

    public var image: OSImage {
        return colorGrid.image
    }
}
