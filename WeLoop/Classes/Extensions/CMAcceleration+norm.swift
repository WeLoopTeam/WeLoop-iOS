//
//  CMAcceleration.swift
//  WeLoop
//
//  Created by Henry Huck on 08/04/2019.
//

import Foundation
import CoreMotion

extension CMAcceleration {
    
    func norm() -> Double {
        return sqrt(pow(self.x, 2) + pow(self.y, 2) + pow(self.z, 2))
    }
}
