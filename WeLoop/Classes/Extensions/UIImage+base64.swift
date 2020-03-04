//
//  UIImage+base64.swift
//  Pods-WeLoop_Example
//
//  Created by Henry Huck on 16/04/2019.
//

import Foundation
import UIKit


extension UIImage {
    
    func toBase64() -> String? {
        guard let base64Data = self.jpegData(compressionQuality: 0.95)?.base64EncodedData() else { return nil }
        return String(data: base64Data, encoding: .utf8)
    }
    
    static func weLoopIcon() -> UIImage?  {
        let bundle = Bundle.weLoop
        return UIImage(named: "WeLoopIcon", in: bundle, compatibleWith: nil)
    }
}
