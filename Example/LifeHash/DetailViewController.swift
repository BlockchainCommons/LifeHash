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

class DetailViewController: UIViewController {
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

    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 20
        return view
    }()

    private lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Self.font
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private lazy var lifeHashView: LifeHashView = {
        let view = LifeHashView(frame: .zero)
        view.constrainAspect()
        return view
    }()

    private func setup() {
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private let tapRecognizer = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()

//        view.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = .clear

        stackView.addArrangedSubview(lifeHashView)
        stackView.addArrangedSubview(label)

        view.addSubview(blurView)
        view.addSubview(stackView)

        blurView.constrainFrameToFrame()
        stackView.constrainCenterToCenter()

        let width: CGFloat = 0.6

        NSLayoutConstraint.activate([
            lifeHashView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: width).setPriority(to: .defaultHigh),
            lifeHashView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: width).setPriority(to: .defaultHigh),
            lifeHashView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: width),
            lifeHashView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: width)
        ])

        tapRecognizer.addTarget(self, action: #selector(didTap))
        view.addGestureRecognizer(tapRecognizer)
    }

    @objc private func didTap(_ recognizer: UIGestureRecognizer) {
        self.dismiss(animated: true)
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
