//
//  UIColor+hex.swift
//  WeLoop
//
//  Created by Henry Huck on 13/04/2019.
//

import UIKit

extension UIColor {
    
    convenience init(hex: Int) {
        
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
    convenience init?(hex: String) {
        let parsedHex = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard let hexInt = Int(parsedHex, radix: 16) else { return nil }
        self.init(hex: hexInt)
    }
}
