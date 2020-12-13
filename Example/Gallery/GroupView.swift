//
//  GroupView.swift
//  LifeHash_Gallery
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 5/4/19.
//

import UIKit

class GroupView: UIView {
    private lazy var columnStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillEqually
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(columnStackView)
        columnStackView.constrainFrameToFrame()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImage(traits: UITraitCollection) {
        func maxCells(for sizeClass: UIUserInterfaceSizeClass) -> Int {
            switch sizeClass {
            case .regular:
                return 4
            default:
                return 2
            }
        }
        let rows = Int.random(in: 1...maxCells(for: traits.verticalSizeClass))
        let columns = Int.random(in: 1...maxCells(for: traits.horizontalSizeClass))

        let columnViews: [UIStackView] = (0 ..< rows).map { _ in
            let rowFrames: [FrameView] = (0 ..< columns).map { _ in
                let view = FrameView(frame: .zero)
                view.updateImage()
                return view
            }
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            view.distribution = .fillEqually
            for frame in rowFrames {
                view.addArrangedSubview(frame)
            }
            return view
        }

        for view in columnStackView.subviews {
            view.removeFromSuperview()
        }
        for view in columnViews {
            columnStackView.addArrangedSubview(view)
        }
    }
}
