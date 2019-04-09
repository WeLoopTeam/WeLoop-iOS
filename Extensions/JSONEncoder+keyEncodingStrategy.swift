//
//  JSONEncoder+keyEncodingStrategy.swift
//  WeLoop
//
//  Created by Henry Huck on 05/04/2019.
//

import Foundation

struct AnyCodingKey: CodingKey {
    
    var stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int? {
        return nil
    }
    
    init?(intValue: Int) {
        return nil
    }
}

extension JSONEncoder.KeyEncodingStrategy {
    
    static var convertToFirstLowerCased: JSONEncoder.KeyEncodingStrategy {
        return .custom { keys in
            
            let key = keys.last! // keys is never empty, and we take the last element of the path
            if key.intValue != nil {
                return key // It's an array key, we don't need to change anything
            }
            return AnyCodingKey(stringValue: key.stringValue.firstLowerCased)!
        }
    }
}
