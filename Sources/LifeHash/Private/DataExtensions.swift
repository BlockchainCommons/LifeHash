//
//  File.swift
//  
//
//  Created by Wolf McNally on 12/11/20.
//

import Foundation

extension Data {
    var hex: String {
        self.reduce("", { $0 + String(format: "%02x", $1) })
    }
}
