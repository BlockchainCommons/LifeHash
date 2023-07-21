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
import Combine
import Dispatch
import CoreGraphics
import CLifeHash

public enum LifeHashVersion: Hashable, CaseIterable {
    case version1
    case version2
    case detailed
    case fiducial
    case grayscaleFiducial
}

public struct LifeHashGenerator {
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
    
    public static func generate(_ obj: Fingerprintable, version: LifeHashVersion = .version1, moduleSize: Int = 1) -> Future<OSImage, Never> {
        return generate(obj.fingerprint, version: version, moduleSize: moduleSize)
    }

    public static func generate(_ fingerprint: Fingerprint, version: LifeHashVersion = .version1, moduleSize: Int = 1) -> Future<OSImage, Never> {
        return Future { promise in
            DispatchQueue.global().async {
                let image = generateSync(fingerprint, version: version, moduleSize: moduleSize)
                promise(.success(image))
            }
        }
    }

    public static func generateSync(_ obj: Fingerprintable, version: LifeHashVersion = .version1, moduleSize: Int = 1) -> OSImage {
        return generateSync(obj.fingerprint, version: version, moduleSize: moduleSize)
    }

    public static func generateSync(_ fingerprint: Fingerprint, version: LifeHashVersion = .version1, moduleSize: Int = 1) -> OSImage {
        
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
