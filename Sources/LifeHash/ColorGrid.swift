//
//  ColorGrid.swift
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
import WolfGraphics

class ColorGrid: Grid<Color> {
    private typealias `Self` = ColorGrid

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

    var image: OSImage {
        let canvas = Canvas(size: size)
        forAll { p in
            canvas[p] = self[p]
        }
        return canvas.image
    }

    override func stringRepresentation(of value: Color) -> String {
        return value.debugSummary
    }
}
