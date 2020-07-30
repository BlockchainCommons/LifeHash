//
//  Color.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation

struct Color: Codable {
    var c: SIMD4<Frac>

    @inlinable var red: Frac {
        get { return c[0] }
        set { c[0] = newValue }
    }

    @inlinable var green: Frac {
        get { return c[1] }
        set { c[1] = newValue }
    }

    @inlinable var blue: Frac {
        get { return c[2] }
        set { c[2] = newValue }
    }

    @inlinable var alpha: Frac {
        get { return c[3] }
        set { c[3] = newValue }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(red)
        try container.encode(green)
        try container.encode(blue)
        try container.encode(alpha)
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let red = try container.decode(Frac.self)
        let green = try container.decode(Frac.self)
        let blue = try container.decode(Frac.self)
        let alpha = try container.decode(Frac.self)
        c = [red, green, blue, alpha]
    }

    @inlinable init(red: Frac, green: Frac, blue: Frac, alpha: Frac = 1.0) {
        c = [red, green, blue, alpha]
    }

    @inlinable init(redByte: UInt8, greenByte: UInt8, blueByte: UInt8, alphaByte: UInt8 = 255) {
        let red = Frac(redByte) / 255.0
        let green = Frac(greenByte) / 255.0
        let blue = Frac(blueByte) / 255.0
        let alpha = Frac(alphaByte) / 255.0
        c = [red, green, blue, alpha]
    }

    @inlinable init(white: Frac, alpha: Frac = 1.0) {
        c = [white, white, white, alpha]
    }

    @inlinable init(data: Data) {
        let r = data[0]
        let g = data[1]
        let b = data[2]
        let a = data.count >= 4 ? data[3] : 255
        self.init(redByte: r, greenByte: g, blueByte: b, alphaByte: a)
    }

    @inlinable init(color: Color, alpha: Frac) {
        c = [color.red, color.green, color.blue, alpha]
    }

//    private static func components(forSingleHexStrings strings: [String], components: inout [Double]) throws {
//        for (index, string) in strings.enumerated() {
//            let i = try (string |> tagHex |> toData)[0]
//            components[index] = Double(i) / 15.0
//        }
//    }
//
//    private static func components(forDoubleHexStrings strings: [String], components: inout [Double]) throws {
//        for (index, string) in strings.enumerated() {
//            let i = try (string |> tagHex |> toData)[0]
//            components[index] = Double(i) / 255.0
//        }
//    }

    private static func components(forFloatStrings strings: [String], components: inout [Double]) throws {
        for (index, string) in strings.enumerated() {
            if let f = Double(string) {
                components[index] = Double(f)
            }
        }
    }

    private static func components(forLabeledStrings strings: [String], components: inout [Double]) throws {
        for (index, string) in strings.enumerated() {
            if let f = Double(string) {
                components[index] = Double(f)
            }
        }
    }

    private static func components(forLabeledHSBStrings strings: [String], components: inout [Double]) throws {
        for (index, string) in strings.enumerated() {
            if let f = Double(string) {
                components[index] = Double(f)
            }
        }
    }

//    init(string s: String) throws {
//        var components: [Double] = [0.0, 0.0, 0.0, 1.0]
//        var isHSB = false
//
//        if let strings = singleHexColorRegex.matchedSubstrings(inString: s) {
//            try type(of: self).components(forSingleHexStrings: strings, components: &components)
//        } else if let strings = doubleHexColorRegex.matchedSubstrings(inString: s) {
//            try type(of: self).components(forDoubleHexStrings: strings, components: &components)
//        } else if let strings = floatColorRegex.matchedSubstrings(inString: s) {
//            try type(of: self).components(forFloatStrings: strings, components: &components)
//        } else if let strings = labeledColorRegex.matchedSubstrings(inString: s) {
//            try type(of: self).components(forLabeledStrings: strings, components: &components)
//        } else if let strings = labeledHSBColorRegex.matchedSubstrings(inString: s) {
//            isHSB = true
//            try type(of: self).components(forLabeledHSBStrings: strings, components: &components)
//        } else {
//            throw WolfColorError("Invalid color string format")
//        }
//
//        if isHSB {
//            self = HSBColor(hue: components[0], saturation: components[1], brightness: components[2], alpha: components[3]) |> toColor
//        } else {
//            self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
//        }
//    }
//
//    static func random(alpha: Frac = 1.0) -> Color {
//        return Color(
//            red: Double.randomFrac(),
//            green: Double.randomFrac(),
//            blue: Double.randomFrac(),
//            alpha: alpha
//        )
//    }

//    static func random<T>(alpha: Frac = 1.0, using generator: inout T) -> Color where T: RandomNumberGenerator {
//        return Color(
//            red: Double.randomFrac(using: &generator),
//            green: Double.randomFrac(using: &generator),
//            blue: Double.randomFrac(using: &generator),
//            alpha: alpha
//        )
//    }

    // NOTE: Not gamma-corrected
    var luminance: Frac {
        return red * 0.2126 + green * 0.7152 + blue * 0.0722
    }

    func withAlphaComponent(_ alpha: Frac) -> Color {
        return Color(color: self, alpha: alpha)
    }

    func multiplied(by rhs: Frac) -> Color {
        return Color(red: red * rhs, green: green * rhs, blue: blue * rhs, alpha: alpha)
    }

    func added(to rhs: Color) -> Color {
        return Color(red: red + rhs.red, green: green + rhs.green, blue: blue + rhs.blue, alpha: alpha)
    }

    func lightened(by frac: Frac) -> Color {
        return Color(
            red: frac.lerpedFromFrac(to: red..1),
            green: frac.lerpedFromFrac(to: green..1),
            blue: frac.lerpedFromFrac(to: blue..1),
            alpha: alpha)
    }

    static func lightened(by frac: Frac) -> (Color) -> Color {
        return { $0.lightened(by: frac) }
    }

    func darkened(by frac: Frac) -> Color {
        return Color(
            red: frac.lerpedFromFrac(to: red..0),
            green: frac.lerpedFromFrac(to: green..0),
            blue: frac.lerpedFromFrac(to: blue..0),
            alpha: alpha)
    }

    static func darkened(by frac: Frac) -> (Color) -> Color {
        return { $0.darkened(by: frac) }
    }

//    /// Identity fraction is 0.0
//    func dodged(by frac: Frac) -> Color {
//        let f = max(1.0 - frac, 1.0e-7)
//        return Color(
//            red: min(red / f, 1.0),
//            green: min(green / f, 1.0),
//            blue: min(blue / f, 1.0),
//            alpha: alpha)
//    }
//
//    static func dodged(by frac: Frac) -> (Color) -> Color {
//        return { $0.dodged(by: frac) }
//    }
//
//    /// Identity fraction is 0.0
//    func burned(by frac: Frac) -> Color {
//        let f = max(1.0 - frac, 1.0e-7)
//        return Color(
//            red: min(1.0 - (1.0 - red) / f, 1.0),
//            green: min(1.0 - (1.0 - green) / f, 1.0),
//            blue: min(1.0 - (1.0 - blue) / f, 1.0),
//            alpha: alpha)
//    }
//
//    static func burned(by frac: Frac) -> (Color) -> Color {
//        return { $0.burned(by: frac) }
//    }

    static let black = Color(red: 0, green: 0, blue: 0, alpha: 1)
//    static let darkGray = Color(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
//    static let lightGray = Color(red: 0.7529411765, green: 0.7529411765, blue: 0.7529411765, alpha: 1)
    static let white = Color(red: 1, green: 1, blue: 1, alpha: 1)
//    static let gray = Color(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
//    static let red = Color(red: 1, green: 0, blue: 0, alpha: 1)
//    static let green = Color(red: 0, green: 1, blue: 0, alpha: 1)
//    static let darkGreen = Color(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
//    static let blue = Color(red: 0, green: 0, blue: 1, alpha: 1)
//    static let cyan = Color(red: 0, green: 1, blue: 1, alpha: 1)
//    static let yellow = Color(red: 1, green: 1, blue: 0, alpha: 1)
//    static let magenta = Color(red: 1, green: 0, blue: 1, alpha: 1)
//    static let orange = Color(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
//    static let purple = Color(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
//    static let brown = Color(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
    static let clear = Color(red: 0, green: 0, blue: 0, alpha: 0)
//    static let pink = Color(red: 1, green: 0.75294118, blue: 0.79607843)
//
//    static let chartreuse = WolfColor.blend(from: .yellow, to: .green, at: 0.5)
//    static let gold = Color(redByte: 251, greenByte: 212, blueByte: 55)
//    static let blueGreen = Color(redByte: 0, greenByte: 169, blueByte: 149)
//    static let mediumBlue = Color(redByte: 0, greenByte: 110, blueByte: 185)
//    static let deepBlue = Color(redByte: 60, greenByte: 55, blueByte: 149)
}

extension Color: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Frac

    init(arrayLiteral elements: Frac...) {
        c = SIMD4<Frac>(elements[0], elements[1], elements[2], elements[3])
    }
}

extension Color: Equatable { }

func == (left: Color, right: Color) -> Bool {
    return left.red == right.red &&
        left.green == right.green &&
        left.blue == right.blue &&
        left.alpha == right.alpha
}

//extension Color: CustomStringConvertible {
//    var description: String {
//        return "Color\(debugSummary)"
//    }
//}

//extension Color {
//    var debugSummary: String {
//        let joiner = Joiner(left: "(", right: ")")
//        var needAlpha = true
//        switch (red, green, blue, alpha) {
//        case (0, 0, 0, 0):
//            joiner.append("clear")
//            needAlpha = false
//        case (0, 0, 0, _):
//            joiner.append("black")
//        case (1, 1, 1, _):
//            joiner.append("white")
//        case (0.5, 0.5, 0.5, _):
//            joiner.append("gray")
//        case (1, 0, 0, _):
//            joiner.append("red")
//        case (0, 1, 0, _):
//            joiner.append("green")
//        case (0, 0, 1, _):
//            joiner.append("blue")
//        case (0, 1, 1, _):
//            joiner.append("cyan")
//        case (1, 0, 1, _):
//            joiner.append("magenta")
//        case (1, 1, 0, _):
//            joiner.append("yellow")
//        default:
//            joiner.append("r:\(String(value: red, precision: 2)) g:\(String(value: green, precision: 2)) b:\(String(value: blue, precision: 2))")
//        }
//        if needAlpha && alpha < 1.0 {
//            joiner.append("a: \(String(value: alpha, precision: 2))")
//        }
//        return joiner.description
//    }
//}

func * (lhs: Color, rhs: Frac) -> Color {
    lhs.multiplied(by: rhs)
}

func + (lhs: Color, rhs: Color) -> Color {
    lhs.added(to: rhs)
}

//extension Color {
//    func blend(to color: Color, at frac: Frac) -> Color {
//        blend(from: self, to: color, at: frac)
////        blend(from: self, to: color, at: frac)
//    }
//}
//
//extension Color: Interpolable {
//    func interpolated(to other: Color, at frac: Frac) -> Color {
//        return blend(to: other, at: frac)
//    }
//}
