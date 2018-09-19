//
//  Gradients.swift
//  LifeHash
//
//  Created by Wolf McNally on 9/17/18.
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
import WolfNumerics
import WolfColor

func selectGradient(entropy: BitEnumerator) -> ColorFunc {
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

private func selectValue(spreadFrac: Frac, centerFrac: Frac, spreadInterval: Interval<Frac>, contrast: Frac, finalInterval: Interval<Frac>, reverse: Bool) -> Interval<Frac> {
    let widenedSpreadFrac = spreadFrac.lerpedFromFrac(to: spreadInterval)
    let spread = (0.5 - widenedSpreadFrac / 2 .. 0.5 + widenedSpreadFrac / 2)
    let c = (centerFrac - 0.5) * (1.0 - spreadFrac)
    let centeredSpread = spread.a + c .. spread.b + c
    let mid = 0.5.lerpedFromFrac(to: centeredSpread)
    let attenuatedA = contrast.lerpedFromFrac(to: mid .. centeredSpread.a)
    let attenuatedB = contrast.lerpedFromFrac(to: mid .. centeredSpread.b)
    let attenuated = attenuatedA .. attenuatedB
    let final = attenuated.lerped(from: 0 .. 1, to: finalInterval)
    let reversed = reverse ? final.swapped() : final
    return reversed
}

private func selectMonochromaticGradient(entropy: BitEnumerator) -> ColorFunc {
    let hue: Frac = entropy.nextFrac()!

    let saturationSpreadFrac = entropy.nextFrac()!
    let saturationCenterFrac = entropy.nextFrac()!
    let saturationReverse = entropy.next()!

    let brightnessSpreadFrac = entropy.nextFrac()!
    let brightnessCenterFrac = entropy.nextFrac()!
    let brightnessReverse = entropy.next()!

    let saturation = selectValue(spreadFrac: saturationSpreadFrac, centerFrac: saturationCenterFrac, spreadInterval: 0.6 .. 1.0, contrast: 1.0, finalInterval: 0.3 .. 1.0, reverse: saturationReverse)
    let brightness = selectValue(spreadFrac: brightnessSpreadFrac, centerFrac: brightnessCenterFrac, spreadInterval: 0.5 .. 1.0, contrast: 1.0, finalInterval: 0.1 .. 1.0, reverse: brightnessReverse)

    let color1 = Color(hue: hue, saturation: saturation.a, brightness: brightness.a)
    let color2 = Color(hue: hue, saturation: saturation.b, brightness: brightness.b)

    return makeTwoColor(color1, color2)
}

private func selectComplementaryGradient(entropy: BitEnumerator) -> ColorFunc {
    let color1Frac = entropy.nextFrac()!

    let saturationSpreadFrac = entropy.nextFrac()!
    let saturationCenterFrac = entropy.nextFrac()!
    let saturationReverse = entropy.next()!

    let brightnessSpreadFrac = entropy.nextFrac()!
    let brightnessCenterFrac = entropy.nextFrac()!
    let brightnessReverse = entropy.next()!

    let color2Frac = (color1Frac + 0.5).truncatingRemainder(dividingBy: 1)
    let saturation = selectValue(spreadFrac: saturationSpreadFrac, centerFrac: saturationCenterFrac, spreadInterval: 0.0 .. 1.0, contrast: 1.0, finalInterval: 0.0 .. 0.2, reverse: saturationReverse)
    let brightness = selectValue(spreadFrac: brightnessSpreadFrac, centerFrac: brightnessCenterFrac, spreadInterval: 0.3 .. 1.0, contrast: 1.0, finalInterval: 0.3 .. 1.0, reverse: brightnessReverse)

    let color1 = spectrum(color1Frac).darkened(by: 1 - brightness.a).lightened(by: saturation.a)
    let color2 = spectrum(color2Frac).darkened(by: 1 - brightness.b).lightened(by: saturation.b)

    return makeTwoColor(color1, color2)
}

private func selectTriadicGradient(entropy: BitEnumerator) -> ColorFunc {
    let color1Frac = entropy.nextFrac()!
    let color2Frac = (color1Frac + 1.0 / 3).truncatingRemainder(dividingBy: 1)
    let color3Frac = (color1Frac + 2.0 / 3).truncatingRemainder(dividingBy: 1)

    let color1 = spectrum(color1Frac).lightened(by: 0.3)
    let color2 = spectrum(color2Frac)
    let color3 = spectrum(color3Frac).darkened(by: 0.3)

    return makeThreeColor(color1, color2, color3)
}

private func selectAnalogousGradient(entropy: BitEnumerator) -> ColorFunc {
    let color1Frac = entropy.nextFrac()!
    let color2Frac = (color1Frac + 1.0 / 12).truncatingRemainder(dividingBy: 1)
    let color3Frac = (color1Frac + 2.0 / 12).truncatingRemainder(dividingBy: 1)
    let color4Frac = (color1Frac + 3.0 / 12).truncatingRemainder(dividingBy: 1)

    let color1 = spectrum(color1Frac).lightened(by: 0.2)
    let color2 = spectrum(color2Frac)
    let color3 = spectrum(color3Frac).darkened(by: 0.2)
    let color4 = spectrum(color4Frac).darkened(by: 0.4)

    return blend(colors: [color1, color2, color3, color4])
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
