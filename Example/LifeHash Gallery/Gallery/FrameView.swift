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
import Interpolate

class FrameView: UIView {
    private let version: LifeHashVersion
    
    private lazy var imageView: LifeHashView = {
        let view = LifeHashView(frame: .zero)
        view.contentMode = .scaleAspectFit
        return view
    }()

    init(version: LifeHashVersion) {
        self.version = version
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        imageView.constrainFrameToFrame(insets: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateImage() {
        let count = 32
        var data = Data(capacity: count)
        (0 ..< count).forEach { _ in
            data.append(UInt8.random(in: 0 ... 255))
        }
        imageView.set(input: data, version: version)
        let colors = imageView.image!.getColors(quality: .highest)!
        let c = colors.nonNeutral ?? .black
        backgroundColor = c.interpolate(to: UIColor.black, at: 0.2)
    }
}

extension UIImageColors {
    var nonNeutral: UIColor? {
        let prioritized = [detail, secondary, primary, background]
        let notBlackOrWhite: [UIColor] = prioritized.compactMap {
            guard let color = $0 else { return nil }
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            if (r, g, b) != (0, 0, 0) && (r, g, b) != (1, 1, 1) {
                return color
            } else {
                return nil
            }
        }
        return notBlackOrWhite.first
    }
}
