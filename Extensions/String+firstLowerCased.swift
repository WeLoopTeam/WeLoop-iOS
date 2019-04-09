//
//  String+Base64.swift
//  Pods-WeLoop_Example
//
//  Created by Henry Huck on 05/04/2019.
//

import Foundation

extension StringProtocol {
    var firstLowerCased: String {
        return prefix(1).lowercased()  + dropFirst()
    }
}
