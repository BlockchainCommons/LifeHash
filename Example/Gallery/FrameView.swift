//
//  FrameView.swift
//  LifeHash_Gallery
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 5/4/19.
//

import LifeHash
import UIImageColors
import UIKit
import WolfNesting
import WolfWith
import WolfViews
import WolfColor

class FrameView: View {
    private lazy var imageView = LifeHashView() • {
        $0.contentMode = .scaleAspectFit
    }

    override func setup() {
        super.setup()

        self => [
            imageView
        ]

        imageView.constrainFrameToFrame(insets: .init(all: 40))
    }

    func updateImage() {
        let count = 32
        var data = Data(capacity: count)
        (0 ..< count).forEach { _ in
            data.append(UInt8.random(in: 0 ... 255))
        }
        imageView.input = data
        let colors = imageView.image!.getColors(quality: .highest)!
        backgroundColor = (colors.nonNeutral ?? .black).darkened(by: 0.2)
    }
}

extension UIImageColors {
    var nonNeutral: UIColor? {
        let prioritized = [detail, secondary, primary, background]
        let notBlackOrWhite: [UIColor] = prioritized.compactMap {
            guard let color = $0 else { return nil }
            let e = Color(color)
            if e != .black && e != .white {
                return color
            } else {
                return nil
            }
        }
        return notBlackOrWhite.first
    }
}
