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
    public let generateAsync: Bool
    public let moduleSize: Int
    
    public var input: Fingerprintable? {
        didSet { fingerprint = input?.fingerprint }
    }
    
    public var version: LifeHashVersion {
        didSet { updateImage() }
    }
    
    public init(version: LifeHashVersion = .version1, generateAsync: Bool = true, moduleSize: Int = 1) {
        self.version = version
        self.generateAsync = generateAsync
        self.moduleSize = moduleSize
    }

    public var fingerprint: Fingerprint? {
        didSet { updateImage() }
    }

    public convenience init(_ fingerprint: Fingerprint? = nil, version: LifeHashVersion = .version1, generateAsync: Bool = true, moduleSize: Int = 1) {
        self.init(version: version, generateAsync: generateAsync, moduleSize: moduleSize)
        self.fingerprint = fingerprint
        updateImage()
    }

    public convenience init(input: Fingerprintable?, version: LifeHashVersion = .version1, generateAsync: Bool = true, moduleSize: Int = 1) {
        self.init(version: version, generateAsync: generateAsync, moduleSize: moduleSize)
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
        if generateAsync {
            cancellable?.cancel()
            cancellable = LifeHashGenerator.getCachedImage(fingerprint, version: version, moduleSize: moduleSize).sink { osImage in
                DispatchQueue.main.async {
                    self.osImage = osImage
                }
            }
        } else {
            self.osImage = LifeHashGenerator.generateSync(fingerprint, version: version, moduleSize: moduleSize)
        }
    }
}
