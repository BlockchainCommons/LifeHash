//
//  LifeHashView.swift
//  LifeHash_Gallery
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 5/3/19.
//

import LifeHash
import UIKit

protocol Fingerprintable {
    var fingerprintInput: Data { get }
}

class LifeHashView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.magnificationFilter = .nearest
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var resetColor: UIColor = .darkGray {
        didSet { backgroundColor = resetColor }
    }

    var fingerprintable: Fingerprintable? = nil {
        didSet { syncToFingerprintable() }
    }

    private(set) var input: Data? = nil
    private(set) var version: LifeHashVersion = .original
    
    func set(input: Data?, version: LifeHashVersion) {
        self.input = input
        self.version = version
        syncToInput()
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
        image = LifeHashGenerator.generateSync(input, version: version)
    }
}
