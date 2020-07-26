//
//  PhotoSettings.swift
//  ImageGenerator
//
//  Created by Turner Eison on 7/26/20.
//  Copyright © 2020 Turner Eison. All rights reserved.
//

import Foundation
import Combine
import UIKit

/// This class holds the necessary information to generate the image
class PhotoSettings: ObservableObject {
    @Published var colors: [RGBA32] = []
    @Published var width = 1600.0
    @Published var height = 1900.0
}

/// 32 bit color (RGBA) for generating pixels from
struct RGBA32: Equatable, Identifiable {
    var color: UInt32
    var id = UUID()
    
    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }
    
    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }
    
    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }
    
    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        color = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | (UInt32(alpha) << 0)
    }
    
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
    
    static let black = RGBA32(red: 0, green: 0, blue: 0, alpha: 255)
    static let red   = RGBA32(red: 255, green: 0, blue: 0, alpha: 255)
    static let green = RGBA32(red: 0, green: 255, blue: 0, alpha: 255)
    static let blue  = RGBA32(red: 0, green: 0, blue: 255, alpha: 255)
}

enum Colors {
    case all
    case specific([RGBA32])
}
