//
//  LifeHashView.swift
//  LifeHash_Gallery
//
//  Created by Wolf McNally on 5/3/19.
//

import WolfKit
import LifeHash
import UIKit

protocol Fingerprintable {
    var fingerprintInput: Data { get }
}

class LifeHashView: ImageView {
    override func setup() {
        super.setup()
        layer.magnificationFilter = .nearest
    }

    var resetColor: UIColor = .darkGray {
        didSet { backgroundColor = resetColor }
    }

    public var fingerprintable: Fingerprintable? = nil {
        didSet { syncToFingerprintable() }
    }

    public var input: Data? = nil {
        didSet { syncToInput() }
    }

    private func syncToFingerprintable() {
        input = fingerprintable?.fingerprintInput
    }

    private func resetView() {
        backgroundColor = .darkGray
        image = nil
    }

    private func syncToInput() {
        guard let input = input else { return }
        image = LifeHash(data: input).image
    }
}
