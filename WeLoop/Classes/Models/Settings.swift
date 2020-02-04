//
//  Settings.swift
//  WeLoop
//
//  Created by Henry Huck on 05/04/2019.
//

import Foundation

struct Settings: Codable {
    
    let iconUrl: String?
    let message: String?
    let position: String?;
    let rgb: Color?
    let language: String;
    
    var primaryColor: UIColor {
        guard let rgb = rgb else { return UIColor.weLoopDefault }
        return UIColor(red: rgb.r / 255, green: rgb.g / 255, blue: rgb.b / 255, alpha: rgb.a)
    }
    
    private enum CodingKeys: String, CodingKey {
        case iconUrl = "Widget_Icon"
        case message = "Widget_Message"
        case position = "Widget_Position"
        case rgb = "Widget_PrimaryColor"
        case language = "Language"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.position = try container.decodeIfPresent(String.self, forKey: .position)
        self.rgb = try container.decodeIfPresent(Color.self, forKey: .rgb)
        self.language = try container.decodeIfPresent(String.self, forKey: .language) ?? "EN"
    }
}


struct Color: Codable {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat
    let a: CGFloat
}

