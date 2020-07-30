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

    @Published var image: Image?

    private var cancellable: AnyCancellable?

    private func updateImage() {
        guard let fingerprint = fingerprint else {
            image = nil
            return
        }
        cancellable?.cancel()
        cancellable = LifeHashGenerator.getCachedImage(fingerprint).sink { image in
            DispatchQueue.main.async {
                self.image = Image(uiImage: image).interpolation(.none)
            }
        }
    }
}
