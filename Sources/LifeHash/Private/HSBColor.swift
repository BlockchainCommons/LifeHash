//
//  HSBColor.swift
//  LifeHash
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation

struct HSBColor: Codable {
    var c: SIMD4<Frac>

    @inlinable var hue: Frac {
        get { return c[0] }
        set { c[0] = newValue }
    }

    @inlinable var saturation: Frac {
        get { return c[1] }
        set { c[1] = newValue }
    }

    @inlinable var brightness: Frac {
        get { return c[2] }
        set { c[2] = newValue }
    }

    @inlinable var alpha: Frac {
        get { return c[3] }
        set { c[3] = newValue }
    }

    @inlinable init(hue: Frac, saturation: Frac, brightness: Frac, alpha: Frac = 1) {
        c = [hue, saturation, brightness, alpha]
    }

    init(_ color: Color) {
        let r = color.red
        let g = color.green
        let b = color.blue
        let alpha = color.alpha

        let maxValue = max(r, g, b)
        let minValue = min(r, g, b)

        let brightness = maxValue

        let d = maxValue - minValue;
        let saturation = maxValue == 0 ? 0 : d / maxValue

        let hue: Frac
        if (maxValue == minValue) {
            hue = 0 // achromatic
        } else {
            switch maxValue {
            case r: hue = ((g - b) / d + (g < b ? 6 : 0)) / 6
            case g: hue = ((b - r) / d + 2) / 6
            case b: hue = ((r - g) / d + 4) / 6
            default: fatalError()
            }
        }
        c = [hue, saturation, brightness, alpha]
    }
}

extension Color {
    init(_ hsb: HSBColor) {
        let v = hsb.brightness.clamped()
        let s = hsb.saturation.clamped()
        let red: Frac
        let green: Frac
        let blue: Frac
        let alpha = hsb.alpha
        if s <= 0.0 {
            red = v
            green = v
            blue = v
        } else {
            var h = hsb.hue.truncatingRemainder(dividingBy: 1.0)
            if h < 0.0 { h += 1.0 }
            h *= 6.0
            let i = Int(floor(h))
            let f = h - Double(i)
            let p = v * (1.0 - s)
            let q = v * (1.0 - (s * f))
            let t = v * (1.0 - (s * (1.0 - f)))
            switch i {
            case 0: red = v; green = t; blue = p
            case 1: red = q; green = v; blue = p
            case 2: red = p; green = v; blue = t
            case 3: red = p; green = q; blue = v
            case 4: red = t; green = p; blue = v
            case 5: red = v; green = p; blue = q
            default: red = 0; green = 0; blue = 0; assert(false, "unknown hue sector")
            }
        }
        self = [red, green, blue, alpha]
    }
}

func toHSBColor(_ c: Color) -> HSBColor {
    return HSBColor(c)
}

func toColor(_ c: HSBColor) -> Color {
    return Color(c)
}
