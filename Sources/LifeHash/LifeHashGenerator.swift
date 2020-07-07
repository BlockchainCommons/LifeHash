//
//  LifeHashGenerator.swift
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

import Foundation
import UIKit
import CryptoKit
import Combine
import Dispatch

public struct LifeHashGenerator {
    public static func generate(_ obj: Fingerprintable) -> Future<UIImage, Never> {
        return generate(digest: obj.fingerprint)
    }

    public static func generate(digest: SHA256Digest) -> Future<UIImage, Never> {
        return Future { promise in
            DispatchQueue.global().async {
                let image = _generate(digest: digest)
                promise(.success(image))
            }
        }
    }

    private static func _generate(digest: SHA256Digest) -> UIImage {
        let size = IntSize(width: 16, height: 16)
        let maxGenerations = 150

        var currentCellGrid = CellGrid(size: size)
        var nextCellGrid = CellGrid(size: size)

        var currentChangeGrid = ChangeGrid(size: size)
        var nextChangeGrid = ChangeGrid(size: size)

        var historySet = Set<Data>()
        var history = [Data]()

        nextCellGrid.data = Data(digest)
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

        let fracGrid = FracGrid(size: size)
        for (index, data) in history.enumerated() {
            currentCellGrid.data = data
            let frac: Frac
            frac = Double(index + 1).lerpedToFrac(from: 0 .. Double(history.count)).clamped()
            fracGrid.overlay(cellGrid: currentCellGrid, frac: frac)
        }

        let entropy = BitEnumerator(data: Data(digest))
        let gradient = selectGradient(entropy: entropy)
        let pattern = selectPattern(entropy: entropy)
        let colorGrid = ColorGrid(fracGrid: fracGrid, gradient: gradient, pattern: pattern)
        return colorGrid.image
    }
}
