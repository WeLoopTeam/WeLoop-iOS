//
//  FloatingButtonController.swift
//  WeLoop
//
//  Created by Henry Huck on 13/04/2019.
//

import UIKit
import Foundation

class FloatingButtonController: UIViewController {
    
    private var position: ButtonPosition
    private var window: FloatingButtonWindow! = FloatingButtonWindow()
    private let button: WeLoopButton

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(settings: Settings) {
        self.position = settings.position 
        self.button = WeLoopButton(frame: .zero)
        super.init(nibName: nil, bundle: nil)

        self.button.configureButton(settings: settings)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = false
        window.rootViewController = self
        
        button.addTarget(WeLoop.shared, action: #selector(WeLoop.invokeSelector), for: .touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(FloatingButtonController.keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FloatingButtonController.keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
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
    
    func setNotificationBadge(count: Int) {
        self.button.setBadge(count: count)
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
