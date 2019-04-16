//
//  window+screenshot.swift
//  Pods-WeLoop_Example
//
//  Created by Henry Huck on 16/04/2019.
//

import Foundation
import UIKit

extension UIWindow {
    
    func takeScreenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
