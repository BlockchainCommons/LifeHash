//
//  Fingerprintable.swift
//  LifeHash
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation
import CryptoKit

public protocol Fingerprintable {
    var fingerprint: SHA256Digest { get }
    var fingerprintData: Data { get }
}

extension Fingerprintable {
    public var fingerprint: SHA256Digest {
        SHA256.hash(data: fingerprintData)
    }
}

extension Data: Fingerprintable {
    public var fingerprintData: Data { self }
}

extension String: Fingerprintable {
    public var fingerprintData: Data { self.data(using: .utf8)! }
}
