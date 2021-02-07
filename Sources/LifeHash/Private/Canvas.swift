//
//  Canvas.swift
//  LifeHash
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 7/6/20.
//

import Foundation
import Accelerate
import CoreGraphics

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

class Canvas {
    let size: IntSize

    private let chunkyBytesCount: Int
    private let planarFloatsCount: Int
    private let planarFloatsPerRow: Int

    private let argb8Data: UnsafeMutablePointer<UInt8>
    private let argb8PremultipliedData: UnsafeMutablePointer<UInt8>
    private let alphaFData: UnsafeMutablePointer<Float>
    private let redFData: UnsafeMutablePointer<Float>
    private let greenFData: UnsafeMutablePointer<Float>
    private let blueFData: UnsafeMutablePointer<Float>

    private var argb8: vImage_Buffer
    private var argb8Premultiplied: vImage_Buffer
    private var alphaF: vImage_Buffer
    private var redF: vImage_Buffer
    private var greenF: vImage_Buffer
    private var blueF: vImage_Buffer

    private var maxPixelValues: [Float] = [1, 1, 1, 1]
    private var minPixelValues: [Float] = [0, 0, 0, 0]
    private let context: CGContext
    private var _image: CGImage?

    init(size: IntSize) {
        self.size = size

        assert(size.width >= 1, "width must be >= 1")
        assert(size.height >= 1, "height must be >= 1")

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let componentsPerPixel = Int(colorSpace.numberOfComponents) + 1 // alpha

        let chunkyBytesPerComponent = 1
        let chunkyBitsPerComponent = chunkyBytesPerComponent * 8
        let chunkyBytesPerPixel = componentsPerPixel * chunkyBytesPerComponent
        let chunkyBytesPerRow = Int(UInt(size.width * chunkyBytesPerPixel + 15) & ~UInt(0xf))
        chunkyBytesCount = size.height * chunkyBytesPerRow

        let planarBytesPerComponent = MemoryLayout<Float>.size
        let planarBytesPerRow = Int(UInt(size.width * planarBytesPerComponent * componentsPerPixel + 15) & ~UInt(0xf))
        planarFloatsPerRow = planarBytesPerRow >> 2
        planarFloatsCount = size.height * planarFloatsPerRow

        argb8Data = UnsafeMutablePointer<UInt8>.allocate(capacity: chunkyBytesCount)
        argb8PremultipliedData = UnsafeMutablePointer<UInt8>.allocate(capacity: chunkyBytesCount)
        alphaFData = UnsafeMutablePointer<Float>.allocate(capacity: planarFloatsCount)
        redFData = UnsafeMutablePointer<Float>.allocate(capacity: planarFloatsCount)
        greenFData = UnsafeMutablePointer<Float>.allocate(capacity: planarFloatsCount)
        blueFData = UnsafeMutablePointer<Float>.allocate(capacity: planarFloatsCount)

        let uWidth = vImagePixelCount(size.width)
        let uHeight = vImagePixelCount(size.height)

        //        argb8 = vImage_Buffer(data: argb8Data, height: uHeight, width: uWidth, rowBytes: chunkyBytesPerRow)
        argb8 = vImage_Buffer(data: argb8Data, height: vImagePixelCount(size.height), width: uWidth, rowBytes: chunkyBytesPerRow)
        argb8Premultiplied = vImage_Buffer(data: argb8PremultipliedData, height: uHeight, width: uWidth, rowBytes: chunkyBytesPerRow)
        alphaF = vImage_Buffer(data: alphaFData, height: uHeight, width: uWidth, rowBytes: planarBytesPerRow)
        redF = vImage_Buffer(data: redFData, height: uHeight, width: uWidth, rowBytes: planarBytesPerRow)
        greenF = vImage_Buffer(data: greenFData, height: uHeight, width: uWidth, rowBytes: planarBytesPerRow)
        blueF = vImage_Buffer(data: blueFData, height: uHeight, width: uWidth, rowBytes: planarBytesPerRow)

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        context = CGContext(data: argb8PremultipliedData, width: size.width, height: size.height, bitsPerComponent: chunkyBitsPerComponent, bytesPerRow: chunkyBytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
    }

    deinit {
        argb8Data.deallocate()
        argb8PremultipliedData.deallocate()
        alphaFData.deallocate()
        redFData.deallocate()
        greenFData.deallocate()
        blueFData.deallocate()
    }
    
    #if canImport(UIKit)
    var image: UIImage {
        UIImage(cgImage: cgImage)
    }
    #elseif canImport(AppKit)
    var image: NSImage {
        let size = CGSize(width: CGFloat(self.size.width), height: CGFloat(self.size.height))
        return NSImage(cgImage: cgImage, size: size)
    }
    #endif

    var cgImage: CGImage {
        get {
            if self._image == nil {
                var error = vImageConvert_PlanarFToARGB8888(&alphaF, &redF, &greenF, &blueF, &argb8, &maxPixelValues, &minPixelValues, UInt32(kvImageNoFlags))
                assert(error == kvImageNoError, "Error when converting canvas to chunky")
                error = vImagePremultiplyData_ARGB8888(&argb8, &argb8Premultiplied, UInt32(kvImageNoFlags))
                assert(error == kvImageNoError, "Error when premultiplying canvas")
                _image = self.context.makeImage()
                assert(self._image != nil, "Error when converting")
            }
            return self._image!
        }
    }

    func invalidateImage() {
        self._image = nil
    }

    private func offsetForPoint(_ point: IntPoint) -> Int {
        return planarFloatsPerRow * point.y + point.x
    }

    func setPoint(_ point: IntPoint, to color: Color) {
        invalidateImage()

        let offset = offsetForPoint(point)
        alphaFData[offset] = 1.0
        redFData[offset] = Float(color.r) / 255
        greenFData[offset] = Float(color.g) / 255
        blueFData[offset] = Float(color.b) / 255
    }
}
