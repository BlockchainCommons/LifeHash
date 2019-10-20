//
//  DetailViewController.swift
//  LifeHash_Example
//
//  Created by Wolf McNally on 12/6/18.
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

import WolfKit
import UIKit

class DetailViewController: ViewController {
    private typealias `Self` = DetailViewController

    var hashTitle: String! {
        get { return label.text }
        set { label.text = newValue }
    }

    var hashInput: Data! {
        get { return lifeHashView.hashInput }
        set { lifeHashView.hashInput = newValue }
    }

    static let fontSize: CGFloat = 24
    static let font = UIFont.boldSystemFont(ofSize: fontSize)
    static let width: CGFloat = 200
    static let imageSize = CGSize(width: width, height: width)

    private lazy var stackView = VerticalStackView() • { (🍒: VerticalStackView) in
        🍒.spacing = 20
    }

    private lazy var blurView = ‡UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    private lazy var label = Label() • { (🍒: Label) in
        🍒.font = Self.font
        🍒.textColor = .label
        🍒.textAlignment = .center
    }

    private lazy var lifeHashView = LifeHashView() • { (🍒: LifeHashView) in
        🍒.constrainAspect()
    }

    override func setup() {
        super.setup()

        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    private var tapAction: GestureRecognizerAction!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        view => [
            blurView,
            stackView => [
                lifeHashView,
                label
            ]
        ]

        blurView.constrainFrameToFrame()
        stackView.constrainCenterToCenter()

        let width: CGFloat = 60%

        Constraints(
            lifeHashView.widthAnchor == view.widthAnchor * width =&= .defaultHigh,
            lifeHashView.heightAnchor == view.heightAnchor * width =&= .defaultHigh,
            lifeHashView.widthAnchor <= view.widthAnchor * width,
            lifeHashView.heightAnchor <= view.heightAnchor * width
        )

        tapAction = view.addAction(for: UITapGestureRecognizer()) { [unowned self] _ in
            self.dismiss()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if isDarkMode(self) {
            blurView.effect = UIBlurEffect(style: .dark)
        } else {
            blurView.effect = UIBlurEffect(style: .light)
        }
    }
}
