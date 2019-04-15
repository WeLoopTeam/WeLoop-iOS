//
//  Authentication.swift
//  WeLoop
//
//  Created by Henry Huck on 04/04/2019.
//

import Foundation

/// URL for authentication. TODO: use pre-processor to switch between env and staging ?
private let authenticationURL = URL(string: "https://staging-api.getweloop.io/api/UnauthorizedData/checkProjectIsVisible")!

struct AuthenticationResponse: Decodable {
    let access: Bool
    let project: Project
}

typealias AuthenticationCallback = (_ project:() throws -> Project) -> Void

func authenticate(apiKey: String, autoAuthentication: Bool, completionHandler: @escaping AuthenticationCallback) -> URLSessionDataTask? {
    
    guard let request = authenticationRequest(apiKey: apiKey, autoAuthentication: autoAuthentication) else {
        return nil
    }
    
    return URLSession(configuration: .default).dataTask(with: request, completionHandler: { (data, response, error) in
        do {
            if let error = error { throw error }
            guard let data = data else { throw WeLoopError.authenticationDataMissing }
            let response = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
            if response.access || !autoAuthentication {
                completionHandler({response.project})
            } else {
                throw WeLoopError.accessDenied
            }
        } catch (let error) {
            completionHandler({ throw error})
        }
    })
}

private func authenticationRequest(apiKey: String, autoAuthentication: Bool) -> URLRequest? {
    var urlRequest = URLRequest(url: authenticationURL)
    urlRequest.httpMethod = "POST";
    urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")

    guard let httpBody = try? JSONSerialization.data(withJSONObject: ["AutoAuthentication": autoAuthentication, "ProjectGuid": apiKey]) else {
        return nil
    }
    urlRequest.httpBody = httpBody
    return urlRequest
}

