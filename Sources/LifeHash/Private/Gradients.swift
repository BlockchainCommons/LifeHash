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
//    let value = 3
    switch value {
    case 0:
        if version == .fiducial {
            return selectMonochromaticGradientV2(entropy: entropy)
        } else {
            return selectMonochromaticGradientV1(entropy: entropy)
        }
    case 1:
        if version == .fiducial {
            return selectComplementaryGradientV2(entropy: entropy)
        } else {
            return selectComplementaryGradientV1(entropy: entropy)
        }
    case 2:
        if version == .fiducial {
            return selectTriadicGradientV2(entropy: entropy)
        } else {
            return selectTriadicGradientV1(entropy: entropy)
        }
    case 3:
        if version == .fiducial {
            return selectAnalogousGradientV2(entropy: entropy)
        } else {
            return selectAnalogousGradientV1(entropy: entropy)
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

private func selectMonochromaticGradientV2(entropy: BitEnumerator) -> Gradient {
    let hue: Frac = entropy.nextFrac()!
    let isReversed = entropy.next()!
    let isTint = entropy.next()!

    let contrastColor: Color = isTint ? .white : .black
    let keyColor = Color(HSBColor(hue: hue, saturation: 1.0, brightness: 1.0)).adjustedForLuminance(relativeTo: contrastColor)

    let gradient = Gradient(blend(colors: [keyColor, contrastColor, keyColor]))
    return isReversed ? gradient.reversed : gradient
}

private func selectMonochromaticGradientV1(entropy: BitEnumerator) -> Gradient {
    let hue: Frac = entropy.nextFrac()!
    let isTint = entropy.next()!
    let isReversed = entropy.next()!
    let keyAdvance = entropy.nextFrac()! * 0.3 + 0.05
    let neutralAdvance = entropy.nextFrac()! * 0.3 + 0.05

    var keyColor = HSBColor(hue: hue, saturation: 1.0, brightness: 1.0) |> toColor

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

private func selectComplementaryGradientV1(entropy: BitEnumerator) -> Gradient {
    let spectrum1 = entropy.nextFrac()!
    let spectrum2 = (spectrum1 + 0.5).truncatingRemainder(dividingBy: 1)
    let lighterAdvance = entropy.nextFrac()! * 0.3
    let darkerAdvance = entropy.nextFrac()! * 0.3
    let isReversed = entropy.next()!

    let color1 = spectrum(spectrum1)
    let color2 = spectrum(spectrum2)

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

private func selectComplementaryGradientV2(entropy: BitEnumerator) -> Gradient {
    let spectrum1 = entropy.nextFrac()!
    let spectrum2 = (spectrum1 + 0.5).truncatingRemainder(dividingBy: 1)
    let isTint = entropy.next()!
    let isReversed = entropy.next()!
    let neutralColorBias = entropy.next()!

    let neutralColor = isTint ? Color.white : Color.black
    let color1 = spectrum(spectrum1)
    let color2 = spectrum(spectrum2)
    
    let biasedNeutralColor = blend(from: neutralColor, to: neutralColorBias ? color1 : color2, at: 0.2).burned(by: 0.1)

    let gradient = Gradient(makeThreeColor(color1.adjustedForLuminance(relativeTo: neutralColor), biasedNeutralColor, color2.adjustedForLuminance(relativeTo: neutralColor)))
    return isReversed ? gradient.reversed : gradient
}

private func selectTriadicGradientV1(entropy: BitEnumerator) -> Gradient {
    let spectrum1 = entropy.nextFrac()!
    let spectrum2 = (spectrum1 + 1.0 / 3).truncatingRemainder(dividingBy: 1)
    let spectrum3 = (spectrum1 + 2.0 / 3).truncatingRemainder(dividingBy: 1)
    let lighterAdvance = entropy.nextFrac()! * 0.3
    let darkerAdvance = entropy.nextFrac()! * 0.3
    let isReversed = entropy.next()!

    let colors = [spectrum(spectrum1), spectrum(spectrum2), spectrum(spectrum3)]
    let sortedColors = colors.sorted { $0.luminance < $1.luminance }

    let darkerColor = sortedColors[0]
    let middleColor = sortedColors[1]
    let lighterColor = sortedColors[2]

    let adjustedLighterColor = blend(from: lighterColor, to: .white, at: lighterAdvance)
    let adjustedDarkerColor = blend(from: darkerColor, to: .black, at: darkerAdvance)

    let gradient = Gradient(makeThreeColor(adjustedLighterColor, middleColor, adjustedDarkerColor))
    return isReversed ? gradient.reversed : gradient
}

private func selectTriadicGradientV2(entropy: BitEnumerator) -> Gradient {
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

private func selectAnalogousGradientV1(entropy: BitEnumerator) -> Gradient {
    let spectrum1 = entropy.nextFrac()!
    let spectrum2 = (spectrum1 + 1.0 / 12).truncatingRemainder(dividingBy: 1)
    let spectrum3 = (spectrum1 + 2.0 / 12).truncatingRemainder(dividingBy: 1)
    let spectrum4 = (spectrum1 + 3.0 / 12).truncatingRemainder(dividingBy: 1)
    let advance = entropy.nextFrac()! * 0.5 + 0.2
    let isReversed = entropy.next()!

    let color1 = spectrum(spectrum1)
    let color2 = spectrum(spectrum2)
    let color3 = spectrum(spectrum3)
    let color4 = spectrum(spectrum4)

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

private func selectAnalogousGradientV2(entropy: BitEnumerator) -> Gradient {
    let spectrum1 = entropy.nextFrac()!
    let spectrum2 = (spectrum1 + 1.0 / 10).truncatingRemainder(dividingBy: 1)
    let spectrum3 = (spectrum1 + 2.0 / 10).truncatingRemainder(dividingBy: 1)
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
