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
import CoreGraphics

public enum LifeHashVersion: Hashable, CaseIterable {
    case version1
    case version2
    case detailed
    case fiducial
    case grayscaleFiducial
}

public struct LifeHashGenerator {
    public static func modules(version: LifeHashVersion) -> Int {
        switch version {
        case .version1, .version2:
            return 32
        case .detailed:
            return 64
        case .fiducial, .grayscaleFiducial:
            return 32
        }
    }
    
    public static func generate(_ obj: Fingerprintable, version: LifeHashVersion = .version1, moduleSize: Int = 1) -> Future<OSImage, Never> {
        return generate(obj.fingerprint, version: version, moduleSize: moduleSize)
    }

    public static func generate(_ fingerprint: Fingerprint, version: LifeHashVersion = .version1, moduleSize: Int = 1) -> Future<OSImage, Never> {
        return Future { promise in
            DispatchQueue.global().async {
                let image = generateSync(fingerprint, version: version, moduleSize: moduleSize)
                promise(.success(image))
            }
        }
    }

    public static func generateSync(_ obj: Fingerprintable, version: LifeHashVersion = .version1, moduleSize: Int = 1) -> OSImage {
        return generateSync(obj.fingerprint, version: version, moduleSize: moduleSize)
    }

    public static func generateSync(_ fingerprint: Fingerprint, version: LifeHashVersion = .version1, moduleSize: Int = 1) -> OSImage {
        let length: Int
        let maxGenerations: Int
        switch version {
        case .version1, .version2:
            length = 16
            maxGenerations = 150
        case .detailed, .fiducial, .grayscaleFiducial:
            length = 32
            maxGenerations = 300
        }

        let size = IntSize(width: length, height: length)

        var currentCellGrid = CellGrid(size: size)
        var nextCellGrid = CellGrid(size: size)

        var currentChangeGrid = ChangeGrid(size: size)
        var nextChangeGrid = ChangeGrid(size: size)

        var historySet = Set<Data>()
        var history = [Data]()

        switch version {
        case .version1:
            nextCellGrid.data = fingerprint.digest
        case .version2:
            // Ensure that .version2 in no way resembles .version1
            nextCellGrid.data = fingerprint.digest.fingerprint.digest
        case .detailed, .fiducial, .grayscaleFiducial:
            var digest1 = fingerprint.digest
            // Ensure that grayscale fiducials in no way resemble the regular color fiducials
            if version == .grayscaleFiducial {
                digest1 = digest1.fingerprint.digest
            }
            let digest2 = digest1.fingerprint.digest
            let digest3 = digest2.fingerprint.digest
            let digest4 = digest3.fingerprint.digest
            nextCellGrid.data = digest1 + digest2 + digest3 + digest4
        }
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
    
        // Normalizing the fracGrid to the range 0..1 was a step left out of .version1
        // In some cases it can cause the full range of the gradient to go unused.
        // This fixes the problem for the other versions, while remaining compatible
        // with .version1.
        if version != .version1 {
            var minValue = Double.infinity
            var maxValue = -Double.infinity
            fracGrid.forAll { p in
                let value = fracGrid[p]
                minValue = min(minValue, value)
                maxValue = max(maxValue, value)
            }
            
            fracGrid.forAll { p in
                fracGrid[p] = fracGrid[p].lerpedToFrac(from: minValue..maxValue)
            }
        }

        let entropy = BitEnumerator(data: fingerprint.digest)
        switch version {
        case .detailed:
            // Throw away a bit of entropy to ensure we generate different colors and patterns from .version1
            _ = entropy.next()
        case .version2:
            // Throw away two bits of entropy to ensure we generate different colors and patterns from .version1 or .detailed.
            _ = entropy.nextUInt2()
        default:
            break
        }
        let gradient = selectGradient(entropy: entropy, version: version)
        let pattern = selectPattern(entropy: entropy, version: version)
        let colorGrid = ColorGrid(fracGrid: fracGrid, gradient: gradient, pattern: pattern)
        assert(moduleSize > 0)
        let scaledImage = colorGrid.image.scaled(by: CGFloat(moduleSize))
        return scaledImage
    }
}
