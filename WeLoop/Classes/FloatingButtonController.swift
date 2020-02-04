//
//  FloatingButtonController.swift
//  WeLoop
//
//  Created by Henry Huck on 13/04/2019.
//

import UIKit
import Foundation

private let margin: CGFloat = 12.0;

@objc public enum ButtonPosition: Int {
    case bottomRight
    case bottomLeft
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

class FloatingButtonController: UIViewController {
    
    private var position: ButtonPosition
    private var window: FloatingButtonWindow! = FloatingButtonWindow()
    private let button: WeLoopButton

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(position: ButtonPosition, settings: Settings) {
        self.position = position
        self.button = WeLoopButton(frame: .zero)
        super.init(nibName: nil, bundle: nil)

        configureButton(settings: settings)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = false
        window.rootViewController = self
        
        button.addTarget(WeLoop.shared, action: #selector(WeLoop.invokeSelector), for: .touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(FloatingButtonController.keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FloatingButtonController.keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    func configureButton(settings: Settings) {
        guard let urlString = settings.iconUrl, let url = URL(string: urlString) else {
            button.color = settings.primaryColor
            button.setImage(UIImage.weLoopIcon(), for: .normal)
            return
        }
    
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData:NSData = NSData(contentsOf: url)!
            
            DispatchQueue.main.async {
                let imageView = UIImageView(frame: self.button.bounds)
                imageView.clipsToBounds = true
                imageView.contentMode = .scaleAspectFill
                imageView.image = UIImage(data: imageData as Data)
                imageView.layer.cornerRadius = 
                self.button.addSubview(imageView)
            }
        }
    }
    
    func tearDown() {
        button.removeTarget(WeLoop.shared, action: #selector(WeLoop.invokeSelector), for: .touchUpInside)
        window.isHidden = true
        window.rootViewController = nil
        window = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        window.button = button
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.center = self.position.socket(view: view, buttonSize: button.bounds.width)
    }
    
    func updatePosition(_ position: ButtonPosition) {
        self.position = position
        view.setNeedsLayout()
    }
    
    func setNotificationBadge(hidden: Bool) {
        self.button.setBadge(hidden: hidden)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        window.windowLevel = UIWindow.Level(rawValue: 0)
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
    }
}

private class FloatingButtonWindow: UIWindow {
    
    var button: UIButton?
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let button = button else { return false }
        let buttonPoint = convert(point, to: button)
        return button.point(inside: buttonPoint, with: event)
    }
}
