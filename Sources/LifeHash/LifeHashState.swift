//
//  LifeHashState.swift
//  LifeHash
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation
import Combine
import UIKit
import Dispatch

public final class LifeHashState: ObservableObject {
    public var input: Fingerprintable? {
        didSet { fingerprint = input?.fingerprint }
    }

    public var fingerprint: Fingerprint? {
        didSet { updateImage() }
    }

    public init(_ fingerprint: Fingerprint? = nil) {
        self.fingerprint = fingerprint
        updateImage()
    }

    @Published var image: UIImage?

    private var cancellable: AnyCancellable?

    private func updateImage() {
        guard let fingerprint = fingerprint else {
            image = nil
            return
        }
        cancellable?.cancel()
        cancellable = LifeHashGenerator.getCachedImage(fingerprint).sink { image in
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
