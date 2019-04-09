//
//  ShakeGestureDetector.swift
//  Pods-WeLoop_Example
//
//  Created by Henry Huck on 08/04/2019.
//

import Foundation
import CoreMotion

class ShakeGestureDetector {
    
    private let motionManager = CMMotionManager()
    private var timer: Timer?
    
    static let shared = ShakeGestureDetector()
    
    private init() {}
    
    func startAccelerometers() {
        // Make sure the accelerometer hardware is available.
        if self.motionManager.isAccelerometerAvailable {
            self.motionManager.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
            self.motionManager.startAccelerometerUpdates()
            
            // Configure a timer to fetch the data.
            self.timer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(ShakeGestureDetector.receivedAcceleration), userInfo: nil, repeats: true);
            
            // Add the timer to the current run loop.
            RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.default)
        }
    }

    @objc func receivedAcceleration() {
        guard let data = self.motionManager.accelerometerData else { return }
        if (data.acceleration.norm() > 5) {
            print("Shake shake shake")
        }
    }
}
