//
//  Project.swift
//  WeLoop
//
//  Created by Henry Huck on 05/04/2019.
//

import Foundation

struct Project: Decodable {
    
    let projectId: Int
    let settings: Settings
    
    private enum CodingKeys: String, CodingKey {
        case projectId = "ProjectId"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Project.CodingKeys.self)
        projectId = try container.decode(Int.self, forKey: .projectId)
        settings = try Settings(from: decoder)
    }
}
