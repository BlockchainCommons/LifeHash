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

extension UUID: Fingerprintable {
    public var fingerprintData: Data {
        withUnsafeBytes(of: self) {
            Data($0.bindMemory(to: UInt8.self))
        }
    }
}

public struct Fingerprint: Equatable {
    public let digest: Data

    public init(digest: Data) {
        assert(digest.count == SHA256.byteCount)
        self.digest = digest
    }

    public func identifier(_ count: Int = 7) -> String {
        String(digest.hex.prefix(count))
    }
}

extension Fingerprint: CustomStringConvertible {
    public var description: String {
        return digest.hex
    }
}
