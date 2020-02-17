//
//  User.swift
//  WeLoop
//
//  Created by Henry Huck on 17/02/2020.
//

import Foundation

@objc public class User: NSObject {
    
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    
    @objc public init(id: String, email: String, firstName: String, lastName: String) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }
        
    func generateToken(appUUID: String) -> String {
        let AES = CryptoJS.AES()
        let message = [email.lowercased(), firstName, lastName, id].joined(separator: "|")
        let token = AES.encrypt(message, password: appUUID)
        return token
    }
}
