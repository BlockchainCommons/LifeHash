//
//  GroupView.swift
//  LifeHash_Gallery
//
//  Created by Wolf McNally on 5/4/19.
//

import WolfKit
import UIKit

class GroupView: View {
    private lazy var columnStackView = StackView() |> vertical |> distribution(.fillEqually)

    override func setup() {
        super.setup()

        self => [
            columnStackView
        ]

        columnStackView.constrainFrameToFrame()
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

        let columnViews: [StackView] = (0 ..< rows).map { _ in
            let rowFrames: [FrameView] = (0 ..< columns).map { _ in
                let view = FrameView()
                view.updateImage()
                return view
            }
            return StackView() |> horizontal |> distribution(.fillEqually) |> addArrangedSubviews(rowFrames)
        }

        columnStackView.removeAllSubviews()
        _ = columnStackView |> addArrangedSubviews(columnViews)
    }
}
