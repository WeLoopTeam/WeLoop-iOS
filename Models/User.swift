//
//  User.swift
//  Pods-WeLoop_Example
//
//  Created by Henry Huck on 05/04/2019.
//

import Foundation

public struct User: Codable {
    
    let firstName: String?
    let lastName: String?
    let email: String?
    
    init(firstName: String, lastName: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    func queryParams() throws -> String {
        let data = try JSONEncoder().encode(self)
        return data.base64EncodedString()
    }
}
