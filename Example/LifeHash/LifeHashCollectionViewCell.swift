//
//  LifeHashCollectionViewCell.swift
//  LifeHash_Example
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
import WolfViews
import WolfWith
import WolfAutolayout
import WolfNesting
import WolfConcurrency
import LifeHash

class LifeHashCollectionViewCell: CollectionViewCell {
    private typealias `Self` = LifeHashCollectionViewCell

    static let imageSize = CGSize(width: 64, height: 64)

    var hashInput: Data? {
        get { return lifeHashView.hashInput }
        set { lifeHashView.hashInput = newValue }
    }

    private lazy var lifeHashView = LifeHashView() • { 🍒 in
        🍒.constrainSize(to: Self.imageSize)
    }

    override func setup() {
        super.setup()

        contentView => [
            lifeHashView
        ]
    }

    override func prepareForReuse() {
        lifeHashView.reset()
    }
}
