//
//  LifeHashCollectionViewCell.swift
//  LifeHash_Example
//
//  Created by Wolf McNally on 9/17/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import WolfViews
import WolfWith
import WolfAutolayout
import WolfNesting
import WolfConcurrency
import LifeHash

class LifeHashCollectionViewCell: CollectionViewCell {
    private typealias `Self` = LifeHashCollectionViewCell

    static let imageSize = CGSize(width: 64, height: 64)

    private var canceler: Cancelable?

    var hashInput: Data! = nil {
        didSet {
            syncToInput()
        }
    }

    private var image: UIImage!

    private lazy var imageView = ImageView() • { 🍒 in
        🍒.constrainSize(to: Self.imageSize)
        🍒.contentMode = .scaleToFill
        🍒.layer.magnificationFilter = .nearest
    }

    override func setup() {
        super.setup()

        contentView => [
            imageView
        ]
    }

    private func reset() {
        canceler?.cancel()
        canceler = nil
        imageView.backgroundColor = .darkGray
        imageView.image = nil
    }

    override func prepareForReuse() {
        reset()
        super.prepareForReuse()
    }

    private func syncToInput() {
        reset()
        canceler = dispatchOnBackground(afterDelay: 0.25) {
            let lifeHash = LifeHash(data: self.hashInput)
            self.image = lifeHash.image
            guard let canceler = self.canceler else { return }
            guard !canceler.isCanceled else { return }
            dispatchOnMain {
                guard !canceler.isCanceled else { return }
                self.imageView.backgroundColor = .clear
                self.imageView.image = self.image
            }
        }
    }
}
