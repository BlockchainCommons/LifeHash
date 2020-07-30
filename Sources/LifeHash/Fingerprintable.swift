//
//  Fingerprintable.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation
import CryptoKit

public protocol Fingerprintable {
    var fingerprintData: Data { get }
    var fingerprint: Fingerprint { get }
}

extension Fingerprintable {
    public var fingerprint: Fingerprint {
        return Fingerprint(digest: Data(SHA256.hash(data: fingerprintData)))
    }
}

extension Data: Fingerprintable {
    public var fingerprintData: Data { self }
}

extension String: Fingerprintable {
    public var fingerprintData: Data { self.data(using: .utf8)! }
}

public struct Fingerprint {
    public let digest: Data

    public init(digest: Data) {
        assert(digest.count == SHA256.byteCount)
        self.digest = digest
    }
}
