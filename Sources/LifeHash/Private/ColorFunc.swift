//
//  ColorFunc.swift
//  LifeHash
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation

struct ColorFuncOptions: OptionSet {
    let rawValue: UInt32

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    static let extendStart = ColorFuncOptions(rawValue: 1 << 0)
    static let extendEnd = ColorFuncOptions(rawValue: 1 << 1)
}

typealias ColorFunc = (_ at: Frac) -> Color

func clamp(at frac: Frac, options: ColorFuncOptions) -> Frac? {
    guard frac >= 0.0 || options.contains(.extendStart) else { return nil }
    guard frac <= 1.0 || options.contains(.extendEnd) else { return nil }
    return frac.clamped()
}

func blend(from color1: Color, to color2: Color, at frac: Frac, alpha: Frac? = nil) -> Color {
    let f = frac.clamped()
    var c = color1 * (1 - f) + color2 * f

    if let alpha = alpha {
        c.alpha = alpha
    } else {
        c.alpha = f.lerpedFromFrac(to: color1.alpha..color2.alpha)
    }

    return c
}

func blend(from color1: Color, to color2: Color, at frac: Frac, options: ColorFuncOptions) -> Color {
    guard clamp(at: frac, options: options) != nil else { return .clear }
    return blend(from: color1, to: color2, at: frac)
}

func blend(from color1: Color, to color2: Color, options: ColorFuncOptions = []) -> ColorFunc {
    return { frac in return blend(from: color1, to: color2, at: frac, options: options) }
}

func makeOneColor(_ color: Color, options: ColorFuncOptions = []) -> ColorFunc {
    return { frac in
        guard clamp(at: frac, options: options) != nil else { return .clear }
        return color
    }
}

func makeTwoColor(_ color1: Color, _ color2: Color, options: ColorFuncOptions = []) -> ColorFunc {
    return blend(from: color1, to: color2, options: options)
}

func makeThreeColor(_ color1: Color, _ color2: Color, _ color3: Color, options: ColorFuncOptions = []) -> ColorFunc {
    return blend(colors: [color1, color2, color3], options: options)
}

func blend(colors: [Color], options: ColorFuncOptions = []) -> ColorFunc {
    let colorsCount = colors.count
    switch colorsCount {
    case 0:
        return makeOneColor(.black, options: options)
    case 1:
        return makeOneColor(colors[0], options: options)
    case 2:
        return makeTwoColor(colors[0], colors[1], options: options)
    default:
        return { frac in
            guard clamp(at: frac, options: options) != nil else { return .clear }
            if frac >= 1.0 {
                return colors.last!
            } else if frac <= 0.0 {
                return colors.first!
            } else {
                let segments = colorsCount - 1
                let s = frac * Double(segments)
                let segment = Int(s)
                let segmentFrac = s.truncatingRemainder(dividingBy: 1.0)
                let c1 = colors[segment]
                let c2 = colors[segment + 1]
                return blend(from: c1, to: c2, at: segmentFrac)
            }
        }
    }
}

func blend(colorFracs: [ColorFrac], options: ColorFuncOptions = []) -> ColorFunc {
    let count = colorFracs.count
    switch count {
    case 0:
        return makeOneColor(.black, options: options)
    case 1:
        return makeOneColor(colorFracs[0].color, options: options)
    case 2:
        return { frac in
            let cf1 = colorFracs[0]
            let cf2 = colorFracs[1]
            let frac = frac.lerpedToFrac(from: cf1.frac..cf2.frac)
            guard let f = clamp(at: frac, options: options) else { return .clear }
            return blend(from: cf1.color, to: cf2.color, at: f)
        }
    default:
        return { frac in
            let f = frac.lerpedToFrac(from: colorFracs.first!.frac..colorFracs.last!.frac)
            guard clamp(at: f, options: options) != nil else { return .clear }
            if frac >= colorFracs.last!.frac {
                return colorFracs.last!.color
            } else if frac <= colorFracs.first!.frac {
                return colorFracs.first!.color
            } else {
                let segments = count - 1
                for segment in 0..<segments {
                    let cf1 = colorFracs[segment]
                    let cf2 = colorFracs[segment + 1]
                    if frac >= cf1.frac && frac < cf2.frac {
                        let f = frac.lerpedToFrac(from: cf1.frac..cf2.frac)
                        return blend(from: cf1.color, to: cf2.color, at: f)
                    }
                }

                return .black
            }
        }
    }
}

func blend(colorFracHandles: [ColorFracHandle], options: ColorFuncOptions = []) -> ColorFunc {
    var colorFracs = [ColorFrac]()
    let count = colorFracHandles.count
    switch count {
    case 0:
        break
    case 1:
        let cfh = colorFracHandles[0]
        colorFracs.append(ColorFrac(cfh.color, cfh.frac))
    default:
        let cfh = colorFracHandles[0]
        colorFracs.append(ColorFrac(cfh.color, cfh.frac))
        for index in 0..<(count - 1) {
            let cfh1 = colorFracHandles[index]
            let cfh2 = colorFracHandles[index + 1]
            if abs(cfh1.handle - 0.5) > 0.001 {
                let color12 = blend(from: cfh1.color, to: cfh2.color, at: 0.5)
                let frac12 = cfh1.handle.lerpedToFrac(from: cfh1.frac..cfh2.frac)
                let colorFrac12 = ColorFrac(color12, frac12)
                colorFracs.append(colorFrac12)
            }
            let colorFrac2 = ColorFrac(cfh2.color, cfh2.frac)
            colorFracs.append(colorFrac2)
        }
    }
    return blend(colorFracs: colorFracs, options: options)
}

func reverse(colorFunc: @escaping ColorFunc) -> ColorFunc {
    return { (frac: Frac) in
        return colorFunc(1 - frac)
    }
}

func tints(hue: Frac, options: ColorFuncOptions = []) -> ColorFunc {
    return { frac in
        guard let f = clamp(at: frac, options: options) else { return .clear }
        return HSBColor(hue: hue, saturation: 1.0 - f, brightness: 1) |> toColor
    }
}

func shades(hue: Frac, options: ColorFuncOptions = []) -> ColorFunc {
    return { frac in
        guard let f = clamp(at: frac, options: options) else { return .clear }
        return HSBColor(hue: hue, saturation: 1.0, brightness: 1.0 - f) |> toColor
    }
}

func tones(hue: Frac, options: ColorFuncOptions = []) -> ColorFunc {
    return { frac in
        guard let f = clamp(at: frac, options: options) else { return .clear }
        return HSBColor(hue: hue, saturation: 1.0 - f, brightness: f.lerpedFromFrac(to: 1.0..0.5)) |> toColor
    }
}
