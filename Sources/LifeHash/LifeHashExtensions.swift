//
//  LifeHashExtensions.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation
import Combine
import SwiftUI

@objc private class DigestKey: NSObject {
    let digest: Data
    let version: LifeHashVersion

    init(digest: Data, version: LifeHashVersion) {
        self.digest = digest
        self.version = version
    }

    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(digest)
        hasher.combine(version)
        return hasher.finalize()
    }

    override func isEqual(_ object: Any?) -> Bool {
        let object = (object as! DigestKey)
        return digest == object.digest && version == object.version
    }
}

extension LifeHashGenerator {
    private static let cache = NSCache<DigestKey, OSImage>()
    private typealias Promise = (Result<OSImage, Never>) -> Void
    private static var promises: [DigestKey: [Promise]] = [:]
    private static let serializer = DispatchQueue(label: "LifeHash serializer")
    private static var cancellables: [DigestKey: AnyCancellable] = [:]

    public static func image(for fingerprint: Fingerprint, version: LifeHashVersion = .version1, moduleSize: Int = 1) -> AnyPublisher<Image, Never> {
        getCachedImage(fingerprint, version: version, moduleSize: moduleSize).map { image in
            Image(osImage: image).interpolation(.none)
        }.eraseToAnyPublisher()
    }

    public static func getCachedImage(_ obj: Fingerprintable, version: LifeHashVersion = .version1, moduleSize: Int = 1) -> Future<OSImage, Never> {
        getCachedImage(obj.fingerprint, version: version, moduleSize: moduleSize)
    }

    public static func getCachedImage(_ fingerprint: Fingerprint, version: LifeHashVersion = .version1, moduleSize: Int = 1) -> Future<OSImage, Never> {
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

        func succeedPromises(for digestKey: DigestKey, with image: OSImage) {
            serializer.sync {
                guard let digestPromises = promises[digestKey] else { return }
                promises.removeValue(forKey: digestKey)
                for promise in digestPromises {
                    promise(.success(image))
                }
            }
        }

        return Future { promise in
            let digestKey = DigestKey(digest: fingerprint.digest, version: version)
            if recordPromise(promise, for: digestKey) {
                if let image = cache.object(forKey: digestKey) {
                    //print("HIT")
                    succeedPromises(for: digestKey, with: image)
                } else {
                    //print("MISS")
                    let cancellable = LifeHashGenerator.generate(fingerprint, version: version, moduleSize: moduleSize).sink { image in
                        serializer.sync {
                            cancellables[digestKey] = nil
                        }
                        cache.setObject(image, forKey: digestKey)
                        succeedPromises(for: digestKey, with: image)
                    }
                    serializer.sync {
                        cancellables[digestKey] = cancellable
                    }
                }
            }
        }
    }
}
