//
//  LifeHashGenerator.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 1/20/16.
//

import Foundation
import CoreGraphics
import CLifeHash
import LRUCache

public enum LifeHashVersion: Hashable, CaseIterable, Sendable {
    case version1
    case version2
    case detailed
    case fiducial
    case grayscaleFiducial
}

public actor LifeHashGenerator {
    public static let shared = LifeHashGenerator()
    
    private let cache: LRUCache<DigestKey, OSImage>
    private var inProgress: [DigestKey: [CheckedContinuation<OSImage, Never>]] = [:]
    
    public init(cacheLimit: Int = 100) {
        cache = LRUCache(countLimit: cacheLimit)
    }
    
    public func image(for fingerprintable: Fingerprintable, version: LifeHashVersion = .version2, moduleSize: Int = 1) async -> OSImage {
        return await image(fingerprint: fingerprintable.fingerprint, version: version, moduleSize: moduleSize)
    }

    public func image(fingerprint: Fingerprint, version: LifeHashVersion = .version2, moduleSize: Int = 1) async -> OSImage {
        // If work is already completed, return it from the cache
        let key = DigestKey(fingerprint: fingerprint, version: version, moduleSize: moduleSize)
        if let image = cache.value(forKey: key) {
//            print("Cache Hit")
            return image
        }
//        print("Cache Miss")

        // If work is already in progress, append the caller to the waiters list and return
        // a continuation
        if inProgress[key] != nil {
//            print("Awaiter Queued")
            return await withCheckedContinuation { continuation in
                inProgress[key, default: []].append(continuation)
            }
        }
        
        // Mark the work in progress and start it
        inProgress[key] = []
        let image = Self.generateSync(fingerprint: fingerprint, version: version, moduleSize: moduleSize)
        cache.setValue(image, forKey: key)
        
        // Retrieve all waiting continuations
        let continuations = inProgress.removeValue(forKey: key) ?? []

        // Resume all waiting continuations with the result
        for continuation in continuations {
            continuation.resume(returning: image)
//            print("Awaiter Resumed")
        }
        
        return image
    }

    public static func modules(version: LifeHashVersion) -> Int {
        switch version {
        case .version1, .version2:
            return 32
        case .detailed:
            return 64
        case .fiducial, .grayscaleFiducial:
            return 32
        }
    }
    
    public static func generateAsync(_ obj: Fingerprintable, version: LifeHashVersion = .version1, moduleSize: Int = 1) async -> OSImage {
        return await generateAsync(fingerprint: obj.fingerprint, version: version, moduleSize: moduleSize)
    }

    public static func generateAsync(fingerprint: Fingerprint, version: LifeHashVersion = .version1, moduleSize: Int = 1) async -> OSImage {
        return generateSync(fingerprint: fingerprint, version: version, moduleSize: moduleSize)
    }

    public static func generateSync(_ obj: Fingerprintable, version: LifeHashVersion = .version1, moduleSize: Int = 1) -> OSImage {
        return generateSync(fingerprint: obj.fingerprint, version: version, moduleSize: moduleSize)
    }

    public static func generateSync(fingerprint: Fingerprint, version: LifeHashVersion = .version1, moduleSize: Int = 1) -> OSImage {
        
        let v: CLifeHash.LifeHashVersion
        switch version {
        case .version1:
            v = lifehash_version1
        case .version2:
            v = lifehash_version2
        case .detailed:
            v = lifehash_detailed
        case .fiducial:
            v = lifehash_fiducial
        case .grayscaleFiducial:
            v = lifehash_grayscale_fiducial
        }
        let im_ptr = fingerprint.digest.withUnsafeBytes {
            lifehash_make_from_digest($0.bindMemory(to: UInt8.self).baseAddress, v, moduleSize, false)
        }
        
        let im = im_ptr!.pointee
        let canvas = Canvas(size: IntSize(width: im.width, height: im.height))
        for y in 0..<im.height {
            for x in 0..<im.width {
                let offset = (y * im.width + x) * 3
                let r = im.colors[offset]
                let g = im.colors[offset + 1]
                let b = im.colors[offset + 2]
                canvas.setPoint(IntPoint(x: x, y: y), to: Color(r: r, g: g, b: b))
            }
        }
        
        lifehash_image_free(im_ptr)

        return canvas.image
    }
}

private struct DigestKey: Hashable {
    let fingerprint: Fingerprint
    let version: LifeHashVersion
    let moduleSize: Int

    init(fingerprint: Fingerprint, version: LifeHashVersion, moduleSize: Int) {
        self.fingerprint = fingerprint
        self.version = version
        self.moduleSize = moduleSize
    }

    var hash: Int {
        var hasher = Hasher()
        hasher.combine(fingerprint)
        hasher.combine(version)
        hasher.combine(moduleSize)
        return hasher.finalize()
    }

    func isEqual(_ object: Any?) -> Bool {
        let object = (object as! DigestKey)
        return fingerprint == object.fingerprint && version == object.version && moduleSize == object.moduleSize
    }
}
