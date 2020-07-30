//
//  ColorGrid.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 9/15/18.
//

import Foundation
import UIKit

class ColorGrid: Grid<Color> {
    enum Pattern {
        case snowflake
        case pinwheel
    }

    init(fracGrid: FracGrid, gradient: Gradient, pattern: Pattern) {
        let size = IntSize(width: fracGrid.size.width * 2, height: fracGrid.size.height * 2)
        super.init(size: size, initialValue: .black)

        let patternTransforms: [Transform]
        switch pattern {
        case .snowflake:
            patternTransforms = Self.snowflakeTransforms
        case .pinwheel:
            patternTransforms = Self.pinwheelTransforms
        }

        fracGrid.forAll { p in
            let color = gradient.at(fracGrid[p])
            draw(p: p, color: color, transforms: patternTransforms)
        }
    }

    private struct Transform {
        let transpose: Bool
        let reflectX: Bool
        let reflectY: Bool
    }

    private static let snowflakeTransforms = [
        Transform(transpose: false, reflectX: false, reflectY: false),
        Transform(transpose: false, reflectX: true, reflectY: false),
        Transform(transpose: false, reflectX: false, reflectY: true),
        Transform(transpose: false, reflectX: true, reflectY: true)
    ]

    private static let pinwheelTransforms = [
        Transform(transpose: false, reflectX: false, reflectY: false),
        Transform(transpose: true, reflectX: true, reflectY: false),
        Transform(transpose: true, reflectX: false, reflectY: true),
        Transform(transpose: false, reflectX: true, reflectY: true)
    ]

    private func draw(p: IntPoint, color: Color, transforms: [Transform]) {
        for t in transforms {
            let p2 = transformPoint(p: p, transpose: t.transpose, reflectX: t.reflectX, reflectY: t.reflectY)
            self[p2] = color
        }
    }

    private func transformPoint(p: IntPoint, transpose: Bool, reflectX: Bool, reflectY: Bool) -> IntPoint {
        var x = p.x
        var y = p.y
        if transpose {
            swap(&x, &y)
        }
        if reflectX {
            x = maxX - x
        }
        if reflectY {
            y = maxY - y
        }
        return IntPoint(x: x, y: y)
    }

    var image: UIImage {
        let canvas = Canvas(size: size)
        forAll { p in
            canvas[p] = self[p]
        }
        return canvas.image
    }

    override func stringRepresentation(of value: Color) -> String {
        return "\(value)"
    }
}
