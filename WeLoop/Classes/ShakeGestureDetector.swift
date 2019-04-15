//
//  ShakeGestureDetector.swift
//  WeLoop
//
//  Created by Henry Huck on 08/04/2019.
//

import Foundation
import CoreMotion

protocol ShakeGestureDelegate: class {
    func didReceiveShakeGesture()
}

private let threshold = 2.5
private let updateInterval = 1.0 / 20.0  // 20 Hz

class ShakeGestureDetector {
    
    private let motionManager = CMMotionManager()
    private var timer: Timer?
    
    weak var delegate: ShakeGestureDelegate?
    
    static let shared = ShakeGestureDetector()
    
    private init() {}
    
    func startAccelerometers() {
        guard self.motionManager.isAccelerometerAvailable else { return }
        
        self.motionManager.accelerometerUpdateInterval = updateInterval
        self.motionManager.startAccelerometerUpdates()
        
        self.timer = Timer(timeInterval: updateInterval, target: self, selector: #selector(ShakeGestureDetector.receivedAcceleration), userInfo: nil, repeats: true);
        RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.default)
    }
    
    func stopAccelerometers() {
        guard self.motionManager.isAccelerometerAvailable else { return }
        self.motionManager.stopAccelerometerUpdates()
    }

    @objc func receivedAcceleration() {
        guard let data = self.motionManager.accelerometerData else { return }
        if (data.acceleration.norm() > threshold) {
            delegate?.didReceiveShakeGesture()
        }
    }
}
