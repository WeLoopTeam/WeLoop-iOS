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
    case accessDenied
    case authenticationDataMissing
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
        case .accessDenied:
            return "You don't have access to this WeLoop project. Try with another project ID"
        case .authenticationDataMissing:
            return "We could not parse the response of the authentication call because the data is missing"
        case .windowMissing:
            return "Failed to acquire a ref to the window"
        case .authenticationInProgress:
            return "Authentication is still in progress"
        }
    }
}
