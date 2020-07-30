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

func selectGradient(entropy: BitEnumerator) -> Gradient {
    switch entropy.nextUInt2() {
    case 0:
        return selectMonochromaticGradient(entropy: entropy)
    case 1:
        return selectComplementaryGradient(entropy: entropy)
    case 2:
        return selectTriadicGradient(entropy: entropy)
    case 3:
        return selectAnalogousGradient(entropy: entropy)
    default:
        fatalError()
    }
}

private func selectMonochromaticGradient(entropy: BitEnumerator) -> Gradient {
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

private func selectComplementaryGradient(entropy: BitEnumerator) -> Gradient {
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

private func selectTriadicGradient(entropy: BitEnumerator) -> Gradient {
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

private func selectAnalogousGradient(entropy: BitEnumerator) -> Gradient {
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

func selectPattern(entropy: BitEnumerator) -> ColorGrid.Pattern {
    return entropy.next()! ? .snowflake : .pinwheel
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
