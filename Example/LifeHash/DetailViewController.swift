//
//  DetailViewController.swift
//  LifeHash_Example
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 12/6/18.
//

import UIKit
import WolfViews
import WolfAutolayout
import WolfWith
import WolfViewControllers
import WolfFoundation
import WolfNesting
import WolfApp
import WolfNumerics

class DetailViewController: ViewController {
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
