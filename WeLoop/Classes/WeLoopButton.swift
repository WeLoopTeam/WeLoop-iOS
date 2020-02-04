//
//  WeLoopswift
//  WeLoop
//
//  Created by Henry Huck on 13/04/2019.
//

import Foundation
import UIKit

private let size: CGFloat = 60.0
private let badgeSize: CGFloat = 24.0

class WeLoopButton: UIButton {
    
    private let badge = UIView(frame: CGRect(x: 0, y: 0, width: badgeSize, height: badgeSize))
    
    var color: UIColor? = nil  {
        didSet {
            backgroundColor = color
        }
    }
    
    override var isHighlighted: Bool {
        willSet {
            layer.shadowOpacity = isHighlighted ? 0.0 : 0.5
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupBadge()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        setupBadge()
    }
    
    func setup() {
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.9
        layer.shadowOffset = CGSize.zero
        
        layer.cornerRadius = size / 2
        
        adjustsImageWhenHighlighted = false

        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: size).isActive = true
        heightAnchor.constraint(equalToConstant: size).isActive = true
    }
    
    func setupBadge() {
        addSubview(badge)
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = .white
        badge.layer.borderColor = UIColor.red.cgColor
        badge.layer.borderWidth = badgeSize / 2 - 2
        badge.layer.cornerRadius = badgeSize / 2
        
        badge.isHidden = true
        
        badge.layer.shadowColor = UIColor.red.cgColor
        badge.layer.shadowRadius = 3
        badge.layer.shadowOpacity = 0.1
        badge.layer.shadowOffset = CGSize.zero
        
        badge.widthAnchor.constraint(equalToConstant: badgeSize).isActive = true
        badge.heightAnchor.constraint(equalToConstant: badgeSize).isActive = true
        badge.centerYAnchor.constraint(equalTo: topAnchor, constant: size / (2 * CGFloat.pi)).isActive = true
        badge.centerXAnchor.constraint(equalTo: rightAnchor, constant: -size / (2 * CGFloat.pi)).isActive =  true
    }
    
    func setBadge(hidden: Bool) {
        badge.isHidden = hidden
    }
}
