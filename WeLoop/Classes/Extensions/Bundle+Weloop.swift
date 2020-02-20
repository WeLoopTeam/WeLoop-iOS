//
//  Bundle+Weloop.swift
//  Pods-WeLoop_Example
//
//  Created by Henry Huck on 20/02/2020.
//

import Foundation

extension Bundle {
    
    static var weLoop: Bundle? {
        guard let url = Bundle(for: WeLoop.self).url(forResource: "WeLoop", withExtension: "bundle") else { return nil }
        return Bundle(url: url)
    }
}
