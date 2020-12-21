//
//  LifeHashState.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation
import Combine
import UIKit
import Dispatch
import SwiftUI

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

    public init(input: Fingerprintable?) {
        self.input = input
        self.fingerprint = input?.fingerprint
        updateImage()
    }

    @Published public var image: Image?
    @Published public var uiImage: UIImage? {
        didSet {
            if let uiImage = uiImage {
                image = Image(uiImage: uiImage).interpolation(.none)
            } else {
                image = nil
            }
        }
    }

    private var cancellable: AnyCancellable?

    private func updateImage() {
        guard let fingerprint = fingerprint else {
            uiImage = nil
            return
        }
        cancellable?.cancel()
        cancellable = LifeHashGenerator.getCachedImage(fingerprint).sink { uiImage in
            DispatchQueue.main.async {
                self.uiImage = uiImage
            }
        }
    }
}
