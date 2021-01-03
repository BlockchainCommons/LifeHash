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
import Dispatch
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class LifeHashState: ObservableObject {
    public var input: Fingerprintable? {
        didSet { fingerprint = input?.fingerprint }
    }
    
    public var version: LifeHashVersion {
        didSet { updateImage() }
    }
    
    public init(version: LifeHashVersion = .original) {
        self.version = version
    }

    public var fingerprint: Fingerprint? {
        didSet { updateImage() }
    }

    public convenience init(_ fingerprint: Fingerprint? = nil, version: LifeHashVersion = .original) {
        self.init(version: version)
        self.fingerprint = fingerprint
        updateImage()
    }

    public convenience init(input: Fingerprintable?, version: LifeHashVersion = .original) {
        self.init(version: version)
        self.input = input
        self.fingerprint = input?.fingerprint
        updateImage()
    }

    @Published public var image: Image?
    @Published public var osImage: OSImage? {
        didSet {
            if let osImage = osImage {
                image = Image(osImage: osImage).interpolation(.none)
            } else {
                image = nil
            }
        }
    }

    private var cancellable: AnyCancellable?

    private func updateImage() {
        guard let fingerprint = fingerprint else {
            osImage = nil
            return
        }
        cancellable?.cancel()
        cancellable = LifeHashGenerator.getCachedImage(fingerprint, version: version).sink { osImage in
            DispatchQueue.main.async {
                self.osImage = osImage
            }
        }
    }
}
