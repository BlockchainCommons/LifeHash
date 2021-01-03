//
//  Gradients.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 9/17/18.
//

import Foundation

func selectGradient(entropy: BitEnumerator, version: LifeHashVersion) -> Gradient {
    if version == .grayscaleFiducial {
        return selectGrayscale(entropy: entropy)
    }
    
    let value = entropy.nextUInt2()
//    let _ = entropy.nextUInt2()
//    let value = 0
    switch value {
    case 0:
        switch version {
        case .version1:
            return selectMonochromaticGradient(entropy: entropy)
        case .version2, .detailed:
            return selectMonochromaticGradientCMYKSafe(entropy: entropy)
        case .fiducial:
            return selectMonochromaticGradientFiducial(entropy: entropy)
        case .grayscaleFiducial:
            fatalError()
        }
    case 1:
        switch version {
        case .version1:
            return selectComplementaryGradient(entropy: entropy)
        case .version2, .detailed:
            return selectComplementaryGradientCMYKSafe(entropy: entropy)
        case .fiducial:
            return selectComplementaryGradientFiducial(entropy: entropy)
        case .grayscaleFiducial:
            fatalError()
        }
    case 2:
        switch version {
        case .version1:
            return selectTriadicGradient(entropy: entropy)
        case .version2, .detailed:
            return selectTriadicGradientCMYKSafe(entropy: entropy)
        case .fiducial:
            return selectTriadicGradientFiducial(entropy: entropy)
        case .grayscaleFiducial:
            fatalError()
        }
    case 3:
        switch version {
        case .version1:
            return selectAnalogousGradient(entropy: entropy)
        case .version2, .detailed:
            return selectAnalogousGradientCMYKSafe(entropy: entropy)
        case .fiducial:
            return selectAnalogousGradientFiducial(entropy: entropy)
        case .grayscaleFiducial:
            fatalError()
        }
    default:
        fatalError()
    }
}

extension Color {
    func adjustedForLuminance(relativeTo contrastColor: Color) -> Color {
        let lum = luminance
        let contrastLum = contrastColor.luminance
        let threshold = 0.6
        let offset = abs(lum - contrastLum)
        guard offset <= threshold else { return self }
        let boost = 0.7
        let t = offset.lerped(from: 0..threshold, to: boost..0)
        if contrastLum > lum {
            // darken this color
            return blend(from: self, to: .black, at: t).burned(by: t * 0.6)
        } else {
            // lighten this color
            return blend(from: self, to: .white, at: t).burned(by: t * 0.6)
        }
    }
}

private func selectGrayscale(entropy: BitEnumerator) -> Gradient {
    entropy.next()! ? .grayscale : Gradient.grayscale.reversed
}

private func selectMonochromaticGradientFiducial(entropy: BitEnumerator) -> Gradient {
    let hue: Frac = entropy.nextFrac()!
    let isReversed = entropy.next()!
    let isTint = entropy.next()!

    let contrastColor: Color = isTint ? .white : .black
    let keyColor = spectrumCMYKSafe(hue).adjustedForLuminance(relativeTo: contrastColor)

    let gradient = Gradient(blend(colors: [keyColor, contrastColor, keyColor]))
    return isReversed ? gradient.reversed : gradient
}

private func selectMonochromaticGradient(entropy: BitEnumerator, hueGenerator: (Frac) -> Color) -> Gradient {
    let hue: Frac = entropy.nextFrac()!
    let isTint = entropy.next()!
    let isReversed = entropy.next()!
    let keyAdvance = entropy.nextFrac()! * 0.3 + 0.05
    let neutralAdvance = entropy.nextFrac()! * 0.3 + 0.05

    var keyColor = hueGenerator(hue)

    let contrastBrightness: Frac
    if isTint {
        contrastBrightness = 1
        keyColor = keyColor.darkened(by: 0.5)
    } else {
        contrastBrightness = 0
    }
    let neutralColor = HSBColor(hue: 0, saturation: 0, brightness: contrastBrightness) |> toColor

    let keyColor2 = blend(from: keyColor, to: neutralColor, at: keyAdvance)
    let neutralColor2 = blend(from: neutralColor, to: keyColor, at: neutralAdvance)

    let gradient = Gradient(makeTwoColor(keyColor2, neutralColor2))
    return isReversed ? gradient.reversed : gradient
}

private func selectMonochromaticGradient(entropy: BitEnumerator) -> Gradient {
    selectMonochromaticGradient(entropy: entropy) { hue in
        Color(HSBColor(hue: hue, saturation: 1.0, brightness: 1.0))
    }
}

private func selectMonochromaticGradientCMYKSafe(entropy: BitEnumerator) -> Gradient {
    selectMonochromaticGradient(entropy: entropy) { hue in
        spectrumCMYKSafe(hue)
    }
}

private func selectComplementaryGradient(entropy: BitEnumerator, colorGenerator: (Frac, Frac) -> (Color, Color)) -> Gradient {
    let spectrum1 = entropy.nextFrac()!
    let spectrum2 = (spectrum1 + 0.5).truncatingRemainder(dividingBy: 1)
    let lighterAdvance = entropy.nextFrac()! * 0.3
    let darkerAdvance = entropy.nextFrac()! * 0.3
    let isReversed = entropy.next()!

    let (color1, color2) = colorGenerator(spectrum1, spectrum2)

    let luma1 = color1.luminance
    let luma2 = color2.luminance

    let darkerColor: Color
    let lighterColor: Color
    if luma1 > luma2 {
        darkerColor = color2
        lighterColor = color1
    } else {
        darkerColor = color1
        lighterColor = color2
    }

    let adjustedLighterColor = blend(from: lighterColor, to: .white, at: lighterAdvance)
    let adjustedDarkerColor = blend(from: darkerColor, to: .black, at: darkerAdvance)

    let gradient = Gradient(makeTwoColor(adjustedDarkerColor, adjustedLighterColor))
    return isReversed ? gradient.reversed : gradient
}

private func selectComplementaryGradient(entropy: BitEnumerator) -> Gradient {
    selectComplementaryGradient(entropy: entropy) { (hue1, hue2) in
        (spectrum(hue1), spectrum(hue2))
    }
}

private func selectComplementaryGradientCMYKSafe(entropy: BitEnumerator) -> Gradient {
    selectComplementaryGradient(entropy: entropy) { (hue1, hue2) in
        (spectrumCMYKSafe(hue1), spectrumCMYKSafe(hue2))
    }
}

private func selectComplementaryGradientFiducial(entropy: BitEnumerator) -> Gradient {
    let spectrum1 = entropy.nextFrac()!
    let spectrum2 = (spectrum1 + 0.5).truncatingRemainder(dividingBy: 1)
    let isTint = entropy.next()!
    let isReversed = entropy.next()!
    let neutralColorBias = entropy.next()!

    let neutralColor = isTint ? Color.white : Color.black
    let color1 = spectrumCMYKSafe(spectrum1)
    let color2 = spectrumCMYKSafe(spectrum2)
    
    let biasedNeutralColor = blend(from: neutralColor, to: neutralColorBias ? color1 : color2, at: 0.2).burned(by: 0.1)

    let gradient = Gradient(makeThreeColor(color1.adjustedForLuminance(relativeTo: neutralColor), biasedNeutralColor, color2.adjustedForLuminance(relativeTo: neutralColor)))
    return isReversed ? gradient.reversed : gradient
}

private func selectTriadicGradient(entropy: BitEnumerator, colorGenerator: (Frac, Frac, Frac) -> (Color, Color, Color)) -> Gradient {
    let spectrum1 = entropy.nextFrac()!
    let spectrum2 = (spectrum1 + 1.0 / 3).truncatingRemainder(dividingBy: 1)
    let spectrum3 = (spectrum1 + 2.0 / 3).truncatingRemainder(dividingBy: 1)
    let lighterAdvance = entropy.nextFrac()! * 0.3
    let darkerAdvance = entropy.nextFrac()! * 0.3
    let isReversed = entropy.next()!

    let (color1, color2, color3) = colorGenerator(spectrum1, spectrum2, spectrum3)
    let colors = [color1, color2, color3]
    let sortedColors = colors.sorted { $0.luminance < $1.luminance }

    let darkerColor = sortedColors[0]
    let middleColor = sortedColors[1]
    let lighterColor = sortedColors[2]

    let adjustedLighterColor = blend(from: lighterColor, to: .white, at: lighterAdvance)
    let adjustedDarkerColor = blend(from: darkerColor, to: .black, at: darkerAdvance)

    let gradient = Gradient(makeThreeColor(adjustedLighterColor, middleColor, adjustedDarkerColor))
    return isReversed ? gradient.reversed : gradient
}

private func selectTriadicGradient(entropy: BitEnumerator) -> Gradient {
    selectTriadicGradient(entropy: entropy) { (hue1, hue2, hue3) in
        (spectrum(hue1), spectrum(hue2), spectrum(hue3))
    }
}

private func selectTriadicGradientCMYKSafe(entropy: BitEnumerator) -> Gradient {
    selectTriadicGradient(entropy: entropy) { (hue1, hue2, hue3) in
        (spectrumCMYKSafe(hue1), spectrumCMYKSafe(hue2), spectrumCMYKSafe(hue3))
    }
}

private func selectTriadicGradientFiducial(entropy: BitEnumerator) -> Gradient {
    let spectrum1 = entropy.nextFrac()!
    let spectrum2 = (spectrum1 + 1.0 / 3).truncatingRemainder(dividingBy: 1)
    let spectrum3 = (spectrum1 + 2.0 / 3).truncatingRemainder(dividingBy: 1)
    let isTint = entropy.next()!
    let neutralInsertIndex = Int(entropy.nextUInt8()!) % 2 + 1
    let isReversed = entropy.next()!

    let neutralColor = isTint ? Color.white : Color.black

    var colors = [spectrum(spectrum1), spectrum(spectrum2), spectrum(spectrum3)]
    switch neutralInsertIndex {
    case 1:
        colors[0] = colors[0].adjustedForLuminance(relativeTo: neutralColor)
        colors[1] = colors[1].adjustedForLuminance(relativeTo: neutralColor)
        colors[2] = colors[2].adjustedForLuminance(relativeTo: colors[1])
    case 2:
        colors[1] = colors[1].adjustedForLuminance(relativeTo: neutralColor)
        colors[2] = colors[2].adjustedForLuminance(relativeTo: neutralColor)
        colors[0] = colors[0].adjustedForLuminance(relativeTo: colors[1])
    default:
        fatalError()
    }
    colors.insert(neutralColor, at: neutralInsertIndex)

    let gradient = Gradient(blend(colors: colors))
    return isReversed ? gradient.reversed : gradient
}

private func selectAnalogousGradient(entropy: BitEnumerator, colorGenerator: (Frac, Frac, Frac, Frac) -> (Color, Color, Color, Color)) -> Gradient {
    let spectrum1 = entropy.nextFrac()!
    let spectrum2 = (spectrum1 + 1.0 / 12).truncatingRemainder(dividingBy: 1)
    let spectrum3 = (spectrum1 + 2.0 / 12).truncatingRemainder(dividingBy: 1)
    let spectrum4 = (spectrum1 + 3.0 / 12).truncatingRemainder(dividingBy: 1)
    let advance = entropy.nextFrac()! * 0.5 + 0.2
    let isReversed = entropy.next()!

    let (color1, color2, color3, color4) = colorGenerator(spectrum1, spectrum2, spectrum3, spectrum4)

    let darkestColor: Color
    let darkColor: Color
    let lightColor: Color
    let lightestColor: Color

    if color1.luminance < color4.luminance {
        darkestColor = color1
        darkColor = color2
        lightColor = color3
        lightestColor = color4
    } else {
        darkestColor = color4
        darkColor = color3
        lightColor = color2
        lightestColor = color1
    }

    let adjustedDarkestColor = blend(from: darkestColor, to: .black, at: advance)
    let adjustedDarkColor = blend(from: darkColor, to: .black, at: advance / 2)
    let adjustedLightColor = blend(from: lightColor, to: .white, at: advance / 2)
    let adjustedLightestColor = blend(from: lightestColor, to: .white, at: advance)

    let gradient = Gradient(blend(colors: [adjustedDarkestColor, adjustedDarkColor, adjustedLightColor, adjustedLightestColor]))
    return isReversed ? gradient.reversed : gradient
}

private func selectAnalogousGradient(entropy: BitEnumerator) -> Gradient {
    selectAnalogousGradient(entropy: entropy) { (hue1, hue2, hue3, hue4) in
        (spectrum(hue1), spectrum(hue2), spectrum(hue3), spectrum(hue4))
    }
}

private func selectAnalogousGradientCMYKSafe(entropy: BitEnumerator) -> Gradient {
    selectAnalogousGradient(entropy: entropy) { (hue1, hue2, hue3, hue4) in
        (spectrumCMYKSafe(hue1), spectrumCMYKSafe(hue2), spectrumCMYKSafe(hue3), spectrumCMYKSafe(hue4))
    }
}

private func selectAnalogousGradientFiducial(entropy: BitEnumerator) -> Gradient {
    let spectrum1 = entropy.nextFrac()!
    let spectrum2 = (spectrum1 + 1.0 / 10).truncatingRemainder(dividingBy: 1)
    let spectrum3 = (spectrum1 + 2.0 / 10).truncatingRemainder(dividingBy: 1)
    let isTint = entropy.next()!
    let neutralInsertIndex = Int(entropy.nextUInt8()!) % 2 + 1
    let isReversed = entropy.next()!

    let neutralColor = isTint ? Color.white : Color.black

    var colors = [spectrumCMYKSafe(spectrum1), spectrumCMYKSafe(spectrum2), spectrumCMYKSafe(spectrum3)]
    switch neutralInsertIndex {
    case 1:
        colors[0] = colors[0].adjustedForLuminance(relativeTo: neutralColor)
        colors[1] = colors[1].adjustedForLuminance(relativeTo: neutralColor)
        colors[2] = colors[2].adjustedForLuminance(relativeTo: colors[1])
    case 2:
        colors[1] = colors[1].adjustedForLuminance(relativeTo: neutralColor)
        colors[2] = colors[2].adjustedForLuminance(relativeTo: neutralColor)
        colors[0] = colors[0].adjustedForLuminance(relativeTo: colors[1])
    default:
        fatalError()
    }
    colors.insert(neutralColor, at: neutralInsertIndex)

    let gradient = Gradient(blend(colors: colors))
    return isReversed ? gradient.reversed : gradient
}

func selectPattern(entropy: BitEnumerator, version: LifeHashVersion) -> ColorGrid.Pattern {
    if version == .fiducial || version == .grayscaleFiducial { return .fiducial }
    let e = entropy.next()!
    return e ? .snowflake : .pinwheel
}

private let spectrum = blend(colors: [
    Color(redByte: 0, greenByte: 168, blueByte: 222),
    Color(redByte: 51, greenByte: 51, blueByte: 145),
    Color(redByte: 233, greenByte: 19, blueByte: 136),
    Color(redByte: 235, greenByte: 45, blueByte: 46),
    Color(redByte: 253, greenByte: 233, blueByte: 43),
    Color(redByte: 0, greenByte: 158, blueByte: 84),
    Color(redByte: 0, greenByte: 168, blueByte: 222)
    ])

private let spectrumCMYKSafe = blend(colors: [
    Color(redByte: 0, greenByte: 168, blueByte: 222),
    Color(redByte: 41, greenByte: 60, blueByte: 130),
    Color(redByte: 210, greenByte: 59, blueByte: 130),
    Color(redByte: 217, greenByte: 63, blueByte: 53),
    Color(redByte: 244, greenByte: 228, blueByte: 81),
    Color(redByte: 0, greenByte: 158, blueByte: 84),
    Color(redByte: 0, greenByte: 168, blueByte: 222)
    ])
