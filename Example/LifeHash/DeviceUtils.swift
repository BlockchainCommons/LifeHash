//
//  DeviceUtils.swift
//  LifeHashExample
//
//  Created by Wolf McNally on 12/13/20.
//

import UIKit

public func isDarkMode(_ traitEnvironment: UITraitEnvironment) -> Bool {
    return traitEnvironment.traitCollection.isDarkMode
}

public var isDarkMode: Bool {
    return isDarkMode(UIScreen.main)
}

extension UITraitCollection {
    public var isDarkMode: Bool {
        if #available(iOS 12, tvOS 10, *) {
            return userInterfaceStyle == .dark
        } else {
            return false
        }
    }
}
