//
//  LifeHashView.swift
//  LifeHash_Example
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 12/5/18.
//

import LifeHash
import UIKit
import WolfViews
import WolfConcurrency
import WolfWith
import WolfPipe
import WolfFoundation
import Combine

class LifeHashView: ImageView {
    private var canceler: Cancelable?

    override func setup() {
        super.setup()
        layer.magnificationFilter = .nearest
        //logger?.setGroup(.cache)
    }

    var hashInput: Data? = nil {
        didSet { syncToInput() }
    }

    func reset() {
        resetView()
        hashInput = nil
    }

    private func set(image: UIImage) {
        self.backgroundColor = .clear
        self.image = image
    }

    private func resetView() {
        backgroundColor = .darkGray
        image = nil
    }

    private var cancellable: AnyCancellable?

    private func syncToInput() {
        resetView()

        guard let hashInput = hashInput else { return }

        self.cancellable = LifeHashGenerator.getCachedImage(hashInput).receive(on: DispatchQueue.main).sink { image in
            guard hashInput == self.hashInput else { return }
            self.set(image: image)
        }
    }
}
