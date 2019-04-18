//
//  WeLoopswift
//  WeLoop
//
//  Created by Henry Huck on 13/04/2019.
//

import Foundation
import UIKit

private let size: CGFloat = 60.0

class WeLoopButton: UIButton {
    
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        setImage(weLoopIcon(), for: .normal)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize.zero
        
        layer.cornerRadius = size / 2
        
        adjustsImageWhenHighlighted = false

        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: size).isActive = true
        heightAnchor.constraint(equalToConstant: size).isActive = true
    }
    
    private func weLoopIcon() -> UIImage?  {
        let bundle = Bundle(for: WeLoopButton.self)
        return UIImage(named: "WeLoopIcon", in: bundle, compatibleWith: nil)
    }
    
    
}
