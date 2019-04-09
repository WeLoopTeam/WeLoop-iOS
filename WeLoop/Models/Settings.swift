//
//  Settings.swift
//  Pods-WeLoop_Example
//
//  Created by Henry Huck on 05/04/2019.
//

import Foundation

struct Settings: Codable {
    let iconUrl: String
    let message: String
    let position: String;
    let primaryColor: String;
    let secondaryColor: String;
    let isBlur: Bool?;
    let language: String?;
    
    private enum CodingKeys: String, CodingKey {
        case iconUrl = "Setting_IconUrl"
        case message = "Setting_Message"
        case position = "Setting_Position"
        case primaryColor = "Setting_PrimaryColor"
        case secondaryColor = "Setting_SecondaryColor"
        case isBlur = "Setting_IsBlur"
        case language = "Setting_lang"
    }
    
    func queryParams() throws -> String {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToFirstLowerCased
        let param = try encoder.encode(self)
        return param.base64EncodedString()
    }
}
