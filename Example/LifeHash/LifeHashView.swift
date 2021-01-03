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
import Combine

public class LifeHashView: UIImageView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.magnificationFilter = .nearest
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public private(set) var hashInput: Data? = nil
    
    public private(set) var version: LifeHashVersion = .version2
    
    public func set(hashInput: Data?, version: LifeHashVersion) {
        self.hashInput = hashInput
        self.version = version
        syncToInput()
    }

    public func reset() {
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

        self.cancellable = LifeHashGenerator.getCachedImage(hashInput, version: version).receive(on: DispatchQueue.main).sink { image in
            guard hashInput == self.hashInput else { return }
            self.set(image: image)
        }
    }
}
