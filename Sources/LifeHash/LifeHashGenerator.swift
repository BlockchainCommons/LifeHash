//
//  LifeHashGenerator.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 1/20/16.
//

import Foundation
import Combine
import Dispatch

public struct LifeHashGenerator {
    public static func generate(_ obj: Fingerprintable) -> Future<OSImage, Never> {
        return generate(obj.fingerprint)
    }

    public static func generate(_ fingerprint: Fingerprint) -> Future<OSImage, Never> {
        return Future { promise in
            DispatchQueue.global().async {
                let image = generateSync(fingerprint)
                promise(.success(image))
            }
        }
    }

    public static func generateSync(_ obj: Fingerprintable) -> OSImage {
        return generateSync(obj.fingerprint)
    }

    public static func generateSync(_ fingerprint: Fingerprint) -> OSImage {
        let size = IntSize(width: 16, height: 16)
        let maxGenerations = 150

        var currentCellGrid = CellGrid(size: size)
        var nextCellGrid = CellGrid(size: size)

        var currentChangeGrid = ChangeGrid(size: size)
        var nextChangeGrid = ChangeGrid(size: size)

        var historySet = Set<Data>()
        var history = [Data]()

        nextCellGrid.data = fingerprint.digest
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

        let entropy = BitEnumerator(data: fingerprint.digest)
        let gradient = selectGradient(entropy: entropy)
        let pattern = selectPattern(entropy: entropy)
        let colorGrid = ColorGrid(fracGrid: fracGrid, gradient: gradient, pattern: pattern)
        return colorGrid.image
    }
}
