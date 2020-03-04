//
//  WeLoopError.swift
//  WeLoop
//
//  Created by Henry Huck on 05/04/2019.
//

import Foundation

@objc public enum WeLoopError: Int, Error {
    case missingAPIKey
    case configurationDataMissing
    case windowMissing
}

extension WeLoopError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .missingAPIKey:
            return "API key is missing. Make sure to call the `initialize` function first"
        case .configurationDataMissing:
            return "We could not parse the response of the configuration call because the data is missing"
        case .windowMissing:
            return "Failed to acquire a ref to the window"
        }
    }
}
