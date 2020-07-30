//
//  Gradient.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation

struct ColorFrac: Equatable {
    let color: Color
    let frac: Double

    init(_ color: Color, _ frac: Frac) {
        self.color = color
        self.frac = frac
    }

    static func == (lhs: ColorFrac, rhs: ColorFrac) -> Bool {
        return lhs.color == rhs.color && lhs.frac == rhs.frac
    }
}

struct ColorFracHandle: Equatable {
    let color: Color
    let frac: Double
    let handle: Double

    init(_ color: Color, _ frac: Frac, _ handle: Double) {
        self.color = color
        self.frac = frac
        self.handle = handle
    }

    static func == (lhs: ColorFracHandle, rhs: ColorFracHandle) -> Bool {
        return lhs.color == rhs.color && lhs.frac == rhs.frac && lhs.handle == rhs.handle
    }
}

struct ColorFracGradient: Equatable {
    let colorFracs: [ColorFrac]

    init(_ colorFracs: [ColorFrac]) {
        self.colorFracs = colorFracs
    }

    static func == (lhs: ColorFracGradient, rhs: ColorFracGradient) -> Bool {
        return lhs.colorFracs == rhs.colorFracs
    }
}

struct ColorFracHandleGradient: Equatable {
    let colorFracHandles: [ColorFracHandle]

    init(_ colorFracHandles: [ColorFracHandle]) {
        self.colorFracHandles = colorFracHandles
    }

    static func == (lhs: ColorFracHandleGradient, rhs: ColorFracHandleGradient) -> Bool {
        return lhs.colorFracHandles == rhs.colorFracHandles
    }
}

struct Gradient {
    let colorFunc: ColorFunc

    init(_ colorFunc: @escaping ColorFunc) {
        self.colorFunc = colorFunc
    }

    func at(_ frac: Frac) -> Color {
        return colorFunc(frac)
    }

    var reversed: Gradient {
        return Gradient({ return self.colorFunc(1 - $0) })
    }
}

func reversed(_ gradient: Gradient) -> Gradient {
    return gradient.reversed
}

extension Gradient {
    static let grayscale = Gradient(blend(from: .black, to: .white))
//
//    // Color Harmonies, Analogous
//    static let goldRedOrange = Gradient(makeThreeColor(.gold, .red, .orange))
//    static let bluegreenBlueGreen = Gradient(makeThreeColor(.blueGreen, .mediumBlue, .darkGreen))
//    static let blueMagentaRed = Gradient(makeThreeColor(.deepBlue, .magenta, .red))
//    static let yellowGoldGreen = Gradient(makeThreeColor(.yellow, .gold, .darkGreen))
//    static let chartreuseYellowGreen = Gradient(makeThreeColor(.chartreuse, .yellow, .darkGreen))
//
//    // Color Harmonies, Primary Complementary
//    static let orangeMediumblue = Gradient(makeTwoColor(.orange, .mediumBlue))
//    static let purpleGold = Gradient(makeTwoColor(.purple, .gold))
//    static let redGreen = Gradient(makeTwoColor(.red, .darkGreen))
//
//    // Color Harmonies, Secondary Complementary
//    static let chartreusePurple = Gradient(makeTwoColor(.chartreuse, .purple))
//    static let greenOrange = Gradient(makeTwoColor(.darkGreen, .orange))
//    static let deepblueOrange = Gradient(makeTwoColor(.deepBlue, .orange))
//
//    // Color Harmonies, Split Complementary
//    static let bluePurpleOrange = Gradient(makeThreeColor(.mediumBlue, .purple, .orange))
//    static let yellowBluePurple = Gradient(makeThreeColor(.yellow, .mediumBlue, .purple))
//    static let chartreuseBlueRed = Gradient(makeThreeColor(.chartreuse, .deepBlue, .red))
//    static let greenMagentaOrange = Gradient(makeThreeColor(.darkGreen, .magenta, .orange))
//    static let bluegreenRedOrange = Gradient(makeThreeColor(.blueGreen, .red, .orange))
//    static let orangeBlueOrange = Gradient(makeThreeColor(.orange, .mediumBlue, .orange))
//    static let goldPurpleOrange = Gradient(makeThreeColor(.gold, .purple, .orange))
//    static let chartreuseBlueOrange = Gradient(makeThreeColor(.chartreuse, .deepBlue, .orange))
//
//    // Earth Tones
//    static let coffee = Gradient(makeThreeColor(
//        Color(redByte: 250, greenByte: 243, blueByte: 232),
//        Color(redByte: 199, greenByte: 152, blueByte: 60),
//        Color(redByte: 191, greenByte: 124, blueByte: 38)))
//    static let valentine = Gradient(makeThreeColor(
//        Color(redByte: 240, greenByte: 222, blueByte: 215),
//        Color(redByte: 178, greenByte: 85, blueByte: 56),
//        Color(redByte: 189, greenByte: 49, blueByte: 26)))
//    static let strata1 = Gradient(blend(colorFracHandles: [
//        ColorFracHandle(Color(redByte: 184, greenByte: 94, blueByte: 66), 0.00, 0.50),
//        ColorFracHandle(Color(redByte: 232, greenByte: 186, blueByte: 128), 0.25, 0.82),
//        ColorFracHandle(Color(redByte: 159, greenByte: 34, blueByte: 20), 0.46, 0.50),
//        ColorFracHandle(Color(redByte: 196, greenByte: 120, blueByte: 105), 0.56, 0.50),
//        ColorFracHandle(Color(redByte: 113, greenByte: 55, blueByte: 31), 0.70, 0.50),
//        ColorFracHandle(Color(redByte: 244, greenByte: 187, blueByte: 58), 1.00, 0.50)
//        ]))
//    static let strata2 = Gradient(blend(colorFracs: [
//        ColorFrac(Color(redByte: 0, greenByte: 89, blueByte: 92), 0.00),
//        ColorFrac(Color(redByte: 166, greenByte: 184, blueByte: 194), 0.25),
//        ColorFrac(Color(redByte: 168, greenByte: 163, blueByte: 155), 0.46),
//        ColorFrac(Color(redByte: 46, greenByte: 52, blueByte: 24), 0.56),
//        ColorFrac(Color(redByte: 106, greenByte: 121, blueByte: 137), 0.70),
//        ColorFrac(Color(redByte: 215, greenByte: 222, blueByte: 226), 1.00)
//        ]))
//    static let strata3 = Gradient(blend(colorFracs: [
//        ColorFrac(Color(redByte: 51, greenByte: 63, blueByte: 41), 0.00),
//        ColorFrac(Color(redByte: 192, greenByte: 152, blueByte: 18), 0.26),
//        ColorFrac(Color(redByte: 176, greenByte: 127, blueByte: 32), 0.35),
//        ColorFrac(Color(redByte: 102, greenByte: 107, blueByte: 67), 0.67),
//        ColorFrac(Color(redByte: 110, greenByte: 79, blueByte: 14), 0.70),
//        ColorFrac(Color(redByte: 135, greenByte: 119, blueByte: 116), 1.00)
//        ]))
//
//    // Seasons
//    static let spring = Gradient(blend(colorFracHandles: [
//        ColorFracHandle(Color(redByte: 172, greenByte: 202, blueByte: 234), 0.00, 0.50),
//        ColorFracHandle(Color(redByte: 207, greenByte: 194, blueByte: 223), 0.22, 0.50),
//        ColorFracHandle(Color(redByte: 249, greenByte: 234, blueByte: 191), 0.43, 0.82),
//        ColorFracHandle(Color(redByte: 227, greenByte: 185, blueByte: 215), 0.72, 0.87),
//        ColorFracHandle(Color(redByte: 172, greenByte: 202, blueByte: 234), 0.74, 0.50),
//        ColorFracHandle(Color(redByte: 201, greenByte: 230, blueByte: 209), 1.00, 0.50)
//        ]))
//    static let summer = Gradient(blend(colorFracHandles: [
//        ColorFracHandle(Color(redByte: 240, greenByte: 200, blueByte: 59), 0.11, 0.50),
//        ColorFracHandle(Color(redByte: 241, greenByte: 86, blueByte: 60), 0.24, 0.40),
//        ColorFracHandle(Color(redByte: 195, greenByte: 75, blueByte: 155), 0.39, 0.50),
//        ColorFracHandle(Color(redByte: 0, greenByte: 179, blueByte: 193), 0.79, 0.50),
//        ColorFracHandle(Color(redByte: 0, greenByte: 179, blueByte: 108), 0.81, 0.50),
//        ColorFracHandle(Color(redByte: 0, greenByte: 179, blueByte: 193), 1.00, 0.50)
//        ]))
//    static let autumn = Gradient(blend(colorFracHandles: [
//        ColorFracHandle(Color(redByte: 118, greenByte: 114, blueByte: 62), 0.00, 0.42),
//        ColorFracHandle(Color(redByte: 220, greenByte: 115, blueByte: 84), 0.24, 0.40),
//        ColorFracHandle(Color(redByte: 255, greenByte: 205, blueByte: 3), 0.69, 0.50),
//        ColorFracHandle(Color(redByte: 220, greenByte: 115, blueByte: 84), 0.81, 0.50),
//        ColorFracHandle(Color(redByte: 148, greenByte: 46, blueByte: 64), 1.00, 0.50)
//        ]))
//    static let winter = Gradient(blend(colorFracHandles: [
//        ColorFracHandle(Color(redByte: 177, greenByte: 199, blueByte: 215), 0.00, 0.50),
//        ColorFracHandle(Color(redByte: 213, greenByte: 217, blueByte: 227), 0.26, 0.50),
//        ColorFracHandle(Color(redByte: 177, greenByte: 199, blueByte: 215), 0.35, 0.50),
//        ColorFracHandle(Color(redByte: 203, greenByte: 209, blueByte: 228), 0.67, 0.50),
//        ColorFracHandle(Color(redByte: 207, greenByte: 223, blueByte: 223), 0.70, 0.50),
//        ColorFracHandle(Color(redByte: 237, greenByte: 217, blueByte: 227), 1.00, 0.50)
//        ]))
//
//    // Nature
//    static let sky1 = Gradient(blend(colorFracHandles: [
//        ColorFracHandle(Color(redByte: 108, greenByte: 181, blueByte: 228), 0.00, 0.60),
//        ColorFracHandle(Color(redByte: 0, greenByte: 124, blueByte: 194), 0.57, 0.50),
//        ColorFracHandle(Color(redByte: 0, greenByte: 89, blueByte: 169), 1.00, 0.50)
//        ]))
//    static let sky2 = Gradient(blend(colorFracHandles: [
//        ColorFracHandle(Color(redByte: 204, greenByte: 224, blueByte: 244), 0.00, 0.60),
//        ColorFracHandle(Color(redByte: 30, greenByte: 156, blueByte: 215), 0.57, 0.50),
//        ColorFracHandle(Color(redByte: 0, greenByte: 117, blueByte: 190), 0.89, 0.50),
//        ColorFracHandle(Color(redByte: 0, greenByte: 90, blueByte: 151), 1.00, 0.50)
//        ]))
//    static let sky3 = Gradient(blend(colorFracHandles: [
//        ColorFracHandle(Color(redByte: 248, greenByte: 209, blueByte: 117), 0.00, 0.46),
//        ColorFracHandle(Color(redByte: 239, greenByte: 145, blueByte: 80), 0.36, 0.52),
//        ColorFracHandle(Color(redByte: 203, greenByte: 114, blueByte: 50), 0.55, 0.50),
//        ColorFracHandle(Color(redByte: 141, greenByte: 74, blueByte: 36), 1.00, 0.50)
//        ]))
//    static let sky4 = Gradient(blend(colorFracHandles: [
//        ColorFracHandle(Color(redByte: 203, greenByte: 114, blueByte: 50), 0.00, 0.46),
//        ColorFracHandle(Color(redByte: 239, greenByte: 145, blueByte: 80), 0.13, 0.52),
//        ColorFracHandle(Color(redByte: 247, greenByte: 210, blueByte: 145), 0.39, 0.48),
//        ColorFracHandle(Color(redByte: 221, greenByte: 188, blueByte: 166), 0.55, 0.50),
//        ColorFracHandle(Color(redByte: 198, greenByte: 169, blueByte: 181), 0.71, 0.50),
//        ColorFracHandle(Color(redByte: 142, greenByte: 98, blueByte: 133), 1.00, 0.38)
//        ]))
//    static let water1 = Gradient(blend(colorFracs: [
//        ColorFrac(Color(redByte: 33, greenByte: 44, blueByte: 41), 0.00),
//        ColorFrac(Color(redByte: 124, greenByte: 170, blueByte: 179), 0.45),
//        ColorFrac(Color(redByte: 141, greenByte: 185, blueByte: 207), 0.60),
//        ColorFrac(Color(redByte: 154, greenByte: 172, blueByte: 203), 0.80),
//        ColorFrac(Color(redByte: 122, greenByte: 127, blueByte: 159), 1.00)
//        ]))
//    static let water2 = Gradient(blend(colors: [
//        Color(redByte: 45, greenByte: 20, blueByte: 79),
//        Color(redByte: 81, greenByte: 46, blueByte: 145),
//        Color(redByte: 74, greenByte: 86, blueByte: 166),
//        Color(redByte: 82, greenByte: 125, blueByte: 191),
//        Color(redByte: 124, greenByte: 187, blueByte: 230),
//        Color(redByte: 199, greenByte: 234, blueByte: 251)
//        ]))
//
//    // Spectra
//    static let redYellowBlue = Gradient(makeThreeColor(.red, .yellow, .blue))
//    static let spectrum = Gradient(blend(colors: [
//        Color(redByte: 0, greenByte: 168, blueByte: 222),
//        Color(redByte: 51, greenByte: 51, blueByte: 145),
//        Color(redByte: 233, greenByte: 19, blueByte: 136),
//        Color(redByte: 235, greenByte: 45, blueByte: 46),
//        Color(redByte: 253, greenByte: 233, blueByte: 43),
//        Color(redByte: 0, greenByte: 158, blueByte: 84)
//        ]))
//    static let hues = Gradient({ HSBColor(hue: $0, saturation: 1, brightness: 1) |> toColor })
//
//    static let gradients: [Gradient] = [
//        .grayscale,
//
//        .goldRedOrange,
//        .bluegreenBlueGreen,
//        .blueMagentaRed,
//        .yellowGoldGreen,
//        .chartreuseYellowGreen,
//
//        .orangeMediumblue,
//        .purpleGold,
//        .redGreen,
//
//        .chartreusePurple,
//        .greenOrange,
//        .deepblueOrange,
//
//        .bluePurpleOrange,
//        .yellowBluePurple,
//        .chartreuseBlueRed,
//        .greenMagentaOrange,
//        .bluegreenRedOrange,
//        .orangeBlueOrange,
//        .goldPurpleOrange,
//        .chartreuseBlueOrange,
//
//        .coffee,
//        .valentine,
//        .strata1,
//        .strata2,
//        .strata3,
//
//        .spring,
//        .summer,
//        .autumn,
//        .winter,
//
//        .sky1,
//        .sky2,
//        .sky3,
//        .sky4,
//        .water1,
//        .water2,
//
//        .hues,
//        .redYellowBlue,
//        .spectrum
//    ]
}
