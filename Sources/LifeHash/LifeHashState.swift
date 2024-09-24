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

@MainActor
public final class LifeHashState: ObservableObject {
    public let generateAsync: Bool
    public let moduleSize: Int
    
    public var input: Fingerprintable? {
        didSet { fingerprint = input?.fingerprint }
    }
    
    public var version: LifeHashVersion {
        didSet { updateImageTask() }
    }

    public var fingerprint: Fingerprint? {
        didSet { updateImageTask() }
    }

    public init(version: LifeHashVersion = .version1, generateAsync: Bool = true, moduleSize: Int = 1) {
        self.version = version
        self.generateAsync = generateAsync
        self.moduleSize = moduleSize
    }

    public convenience init(_ fingerprint: Fingerprint? = nil, version: LifeHashVersion = .version1, generateAsync: Bool = true, moduleSize: Int = 1) {
        self.init(version: version, generateAsync: generateAsync, moduleSize: moduleSize)
        self.fingerprint = fingerprint
        updateImageTask()
    }

    public convenience init(input: Fingerprintable?, version: LifeHashVersion = .version1, generateAsync: Bool = true, moduleSize: Int = 1) {
        self.init(version: version, generateAsync: generateAsync, moduleSize: moduleSize)
        self.input = input
        self.fingerprint = input?.fingerprint
        updateImageTask()
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
    
    private var taskInProgress: Task<Void, Never>?

    private func updateImageTask() {
        if let taskInProgress {
            taskInProgress.cancel()
        }
        taskInProgress = Task {
            await updateImage()
        }
    }

    private func updateImage() async {
        guard let fingerprint else {
            osImage = nil
            return
        }
        if generateAsync {
            self.osImage = await LifeHashGenerator.shared.image(fingerprint: fingerprint, version: version, moduleSize: moduleSize)
        } else {
            self.osImage = LifeHashGenerator.generateSync(fingerprint: fingerprint, version: version, moduleSize: moduleSize)
        }
    }
}
