//
//  LifeHashView.swift
//  LifeHash_Gallery
//
//  Created by Wolf McNally on 5/3/19.
//

import WolfKit
import LifeHash

protocol Fingerprintable {
    var fingerprintInput: Data { get }
}

class LifeHashView: ImageView {
    private typealias `Self` = LifeHashView

    override func setup() {
        super.setup()
        layer.magnificationFilter = .nearest
        reset()
        //logger?.setGroup(.cache)
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

    func reset() {
        resetView()
        input = nil
    }

    func set(image: UIImage) {
        self.backgroundColor = .clear
        self.image = image
    }

    private func syncToFingerprintable() {
        input = fingerprintable?.fingerprintInput
    }

    private func resetView() {
        backgroundColor = .darkGray
        image = nil
    }

    private func syncToInput() {
        resetView()

        guard let input = input else { return }
        _ = LifeHash.getImageForInput(input).map { image in
            guard self.input == input else { return }
            self.set(image: image)
        }
    }
}
