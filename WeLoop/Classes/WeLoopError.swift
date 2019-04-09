//
//  WeLoopError.swift
//  Pods-WeLoop_Example
//
//  Created by Henry Huck on 05/04/2019.
//

import Foundation

@objc public enum WeLoopError: Int, Error {
    case requiresAccess
    case authenticationDataMissing
    case authenticationFailed
}
