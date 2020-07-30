//
//  LifeHashCollectionViewCell.swift
//  LifeHash_Example
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 9/17/18.
//

import Foundation
import LifeHash
import UIKit
import WolfViews
import WolfWith
import WolfNesting

class LifeHashCollectionViewCell: CollectionViewCell {
    static let imageHeight: CGFloat = 64
    static let width: CGFloat = 64
    static let spacing: CGFloat = 5
    static let height = imageHeight + spacing + labelHeight
    static let imageSize = CGSize(width: width, height: imageHeight)
    static let size = CGSize(width: width, height: height)
    static let fontSize: CGFloat = 14
    static let font = UIFont.boldSystemFont(ofSize: fontSize)
    static let labelHeight = font.lineHeight

    var hashInput: Data? {
        get { return lifeHashView.hashInput }
        set { lifeHashView.hashInput = newValue }
    }

    var hashTitle: String? {
        didSet {
            label.text = hashTitle
        }
    }

    private lazy var stackView = VerticalStackView() • { (🍒: VerticalStackView) in
        🍒.spacing = Self.spacing
    }

    private lazy var label = Label() • { (🍒: Label) in
        🍒.font = Self.font
        🍒.textColor = .label
        🍒.textAlignment = .center
        🍒.constrainHeight(to: Self.labelHeight)
    }

    private lazy var lifeHashView = LifeHashView() • { 🍒 in
        🍒.constrainSize(to: Self.imageSize)
    }

    override func setup() {
        super.setup()

        contentView => [
            stackView => [
                lifeHashView,
                label
            ]
        ]
    }

    override func prepareForReuse() {
        lifeHashView.reset()
    }
}
