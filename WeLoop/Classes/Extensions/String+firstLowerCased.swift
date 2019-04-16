//
//  String+Base64.swift
//  WeLoop
//
//  Created by Henry Huck on 05/04/2019.
//

import Foundation

extension StringProtocol {
    
    /// Returns the string, with its first character lowercased
    var firstLowerCased: String {
        return prefix(1).lowercased()  + dropFirst()
    }
}
