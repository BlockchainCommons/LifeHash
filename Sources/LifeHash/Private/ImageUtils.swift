//
//  ImageUtils.swift
//  
//
//  Created by Wolf McNally on 2/4/21.
//

#if canImport(UIKit)

import UIKit

extension UIImage {
    func resized(to targetSize: CGSize, interpolationQuality: CGInterpolationQuality = .none) -> UIImage {
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = interpolationQuality
        draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func scaled(by scale: CGFloat, interpolationQuality: CGInterpolationQuality = .none) -> UIImage {
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        return resized(to: scaledSize, interpolationQuality: interpolationQuality)
    }
}

#elseif canImport(AppKit)

import AppKit

extension NSImage {
    func pngData() throws -> Data {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw ToolError.developer("Unable to get CGImage.")
        }
        let imageRep = NSBitmapImageRep(cgImage: cgImage)
        imageRep.size = size // display size in points
        return imageRep.representation(using: .png, properties: [:])!
    }
    
    func resized(to newSize: NSSize) -> NSImage {
        let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        )!
        bitmapRep.size = newSize
        
        NSGraphicsContext.saveGraphicsState()
        let context = NSGraphicsContext(bitmapImageRep: bitmapRep)!
        context.imageInterpolation = .none
        NSGraphicsContext.current = context
        draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        
        let resizedImage = NSImage(size: newSize)
        resizedImage.addRepresentation(bitmapRep)
        return resizedImage
    }
    
    func resized(to newSize: CGFloat) -> NSImage {
        resized(to: CGSize(width: newSize, height: newSize))
    }
}

#endif
