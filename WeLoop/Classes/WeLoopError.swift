//
//  WeLoopError.swift
//  WeLoop
//
//  Created by Henry Huck on 05/04/2019.
//

import Foundation

@objc public enum WeLoopError: Int, Error {
    case missingAPIKey
    case missingUserIdentification
    case configurationDataMissing
    case notificationDataMissing
    case windowMissing
    case authenticationInProgress
}

extension WeLoopError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .missingAPIKey:
            return "API key is missing. Make sure to call the `initialize` function first"
        case .missingUserIdentification:
            return "User info is missing. Make sure to call the `identifyUser` function first"
        case .notificationDataMissing:
            return "We could not parse the response of the notification refresh call because the data is missing"
        case .configurationDataMissing:
            return "We could not parse the response of the configuration call because the data is missing"
        case .windowMissing:
            return "Failed to acquire a ref to the window"
        case .authenticationInProgress:
            return "Authentication is still in progress"
        }
    }
}
