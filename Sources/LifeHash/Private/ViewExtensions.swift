//
//  ViewExtensions.swift
//  LifeHash
//
//  Created by Wolf McNally on 12/31/20.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Image {
    init(osImage: OSImage) {
        #if canImport(UIKit)
        self = Image(uiImage: osImage)
        #elseif canImport(AppKit)
        self = Image(nsImage: osImage)
        #endif
    }
}
