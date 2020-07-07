//
//  LifeHashExtensions.swift
//  LifeHash
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation
import CryptoKit
import UIKit
import Combine

extension LifeHashGenerator {
    private final class DigestKey: Hashable, Equatable {
        let digest: SHA256Digest

        init(_ digest: SHA256Digest) { self.digest = digest }

        func hash(into hasher: inout Hasher) { hasher.combine(digest) }
        static func ==(lhs: DigestKey, rhs: DigestKey) -> Bool { lhs.digest == rhs.digest }
    }

    private static let cache = NSCache<DigestKey, UIImage>()
    private typealias Promise = (Result<UIImage, Never>) -> Void
    private static var promises: [DigestKey: [Promise]] = [:]
    private static let serializer = DispatchQueue(label: "LifeHash serializer")
    private static var cancellables: [DigestKey: AnyCancellable] = [:]

    static func getImageForDigest(_ digest: SHA256Digest) -> Future<UIImage, Never> {
        /// Additional requests for the same LifeHash image while one is already in progress are recorded,
        /// and all are responded to when the image is done. This is so almost-simultaneous requests for the
        /// same data don't trigger duplicate work.
        func recordPromise(_ promise: @escaping Promise, for digestKey: DigestKey) -> Bool {
            var result: Bool!
            serializer.sync {
                if let digestPromises = promises[digestKey] {
                    var p = digestPromises
                    p.append(promise)
                    promises[digestKey] = p
                    result = false
                } else {
                    promises[digestKey] = [promise]
                    result = true
                }
            }
            return result
        }

        func succeedPromises(for digestKey: DigestKey, with image: UIImage) {
            serializer.sync {
                guard let digestPromises = promises[digestKey] else { return }
                promises.removeValue(forKey: digestKey)
                for promise in digestPromises {
                    promise(.success(image))
                }
            }
        }

        return Future { promise in
            let digestKey = DigestKey(digest)
            if recordPromise(promise, for: digestKey) {
                if let image = cache.object(forKey: digestKey) {
                    succeedPromises(for: digestKey, with: image)
                } else {
                    cancellables[digestKey] = LifeHashGenerator.generate(digest: digestKey.digest).sink { image in
                        cancellables.removeValue(forKey: digestKey)
                        cache.setObject(image, forKey: digestKey)
                        succeedPromises(for: digestKey, with: image)
                    }
                }
            }
        }
    }
}
