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
import CryptoKit

public final class LifeHashState: ObservableObject {
    public var input: Fingerprintable? {
        didSet { digest = input?.fingerprint }
    }

    public var digest: SHA256Digest? {
        didSet { updateImage() }
    }

    public init(_ digest: SHA256Digest? = nil) {
        self.digest = digest
        updateImage()
    }

    @Published var image: UIImage?

    private var cancellable: AnyCancellable?

    private func updateImage() {
        guard let digest = digest else {
            image = nil
            return
        }
        cancellable?.cancel()
        cancellable = LifeHashGenerator.getImageForDigest(digest).sink { image in
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
