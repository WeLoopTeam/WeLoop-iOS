//
//  ButtonPosition.swift
//  Pods-WeLoop_Example
//
//  Created by Henry Huck on 17/02/2020.
//

import Foundation

private let margin: CGFloat = 12.0;

enum ButtonPosition: String, Codable {
    case bottomRight = "Right"
    case bottomLeft = "Left"
    case topLeft 
    case topRight
    
    func socket(view: UIView, buttonSize: CGFloat) -> CGPoint {
        let rect = view.bounds.insetBy(dx: margin + buttonSize / 2, dy: margin + buttonSize / 2)
        switch self {
        case .bottomRight:
            return CGPoint(x: rect.maxX, y: rect.maxY)
        case .bottomLeft:
            return CGPoint(x: rect.minX, y: rect.maxY)
        case .topLeft:
            return CGPoint(x: rect.minX, y: rect.minY)
        case .topRight:
            return CGPoint(x: rect.maxX, y: rect.minY)
        }
    }
}
