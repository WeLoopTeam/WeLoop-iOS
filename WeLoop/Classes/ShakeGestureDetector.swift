//
//  ShakeGestureDetector.swift
//  Pods-WeLoop_Example
//
//  Created by Henry Huck on 08/04/2019.
//

import Foundation
import CoreMotion

protocol ShakeGestureDelegate: class {
    func didReceiveShakeGesture()
}

private let threshold = 4.0
private let updateInterval = 1.0 / 10.0  // 10 Hz

class ShakeGestureDetector {
    
    private let motionManager = CMMotionManager()
    private var timer: Timer?
    
    weak var delegate: ShakeGestureDelegate?
    
    static let shared = ShakeGestureDetector()
    
    private init() {}
    
    func startAccelerometers() {
        // Make sure the accelerometer hardware is available.
        if self.motionManager.isAccelerometerAvailable {
            self.motionManager.accelerometerUpdateInterval = updateInterval
            self.motionManager.startAccelerometerUpdates()
            
            // Configure a timer to fetch the data.
            self.timer = Timer(timeInterval: updateInterval, target: self, selector: #selector(ShakeGestureDetector.receivedAcceleration), userInfo: nil, repeats: true);
            
            // Add the timer to the current run loop.
            RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.default)
        }
    }

    @objc func receivedAcceleration() {
        guard let data = self.motionManager.accelerometerData else { return }
        if (data.acceleration.norm() > threshold) {
            delegate?.didReceiveShakeGesture()
        }
    }
}
