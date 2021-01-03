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

class LifeHashCollectionViewCell: UICollectionViewCell {
    static let imageHeight: CGFloat = 96
    static let width: CGFloat = 96
    static let spacing: CGFloat = 10
    static let height = imageHeight + spacing + labelHeight
    static let imageSize = CGSize(width: width, height: imageHeight)
    static let size = CGSize(width: width, height: height)
    static let fontSize: CGFloat = 14
    static let font = UIFont.boldSystemFont(ofSize: fontSize)
    static let labelHeight = font.lineHeight

    var hashInput: Data? {
        lifeHashView.hashInput
    }
    
    var version: LifeHashVersion {
        return lifeHashView.version
    }
    
    func set(hashInput: Data?, version: LifeHashVersion) {
        lifeHashView.set(hashInput: hashInput, version: version)
    }

    var hashTitle: String? {
        didSet {
            label.text = hashTitle
        }
    }

    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = Self.spacing
        return view
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Self.font
        label.textColor = .label
        label.textAlignment = .center
        label.constrainHeight(to: Self.labelHeight)
        return label
    }()

    private lazy var lifeHashView: LifeHashView = {
        let view = LifeHashView(frame: .zero)
        view.constrainSize(to: Self.imageSize)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        // https://stackoverflow.com/questions/24750158/autoresizing-issue-of-uicollectionviewcell-contentviews-frame-in-storyboard-pro
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        stackView.addArrangedSubview(lifeHashView)
        stackView.addArrangedSubview(label)

        contentView.addSubview(stackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        lifeHashView.reset()
    }
}
