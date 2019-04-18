//
//  Authentication.swift
//  WeLoop
//
//  Created by Henry Huck on 04/04/2019.
//

import Foundation

struct AuthenticationResponse: Decodable {
    let access: Bool
    let project: Project
}

typealias AuthenticationCallback = (_ project:() throws -> Project) -> Void

extension WeLoop {
    func authenticate(completionHandler: @escaping AuthenticationCallback) -> URLSessionDataTask? {
        
        guard let request = authenticationRequest() else {
            return nil
        }
        let autoAuthentication = self.autoAuthentication
        
        return URLSession(configuration: .default).dataTask(with: request, completionHandler: { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw WeLoopError.authenticationDataMissing }
                
                let response = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
                if response.access || !autoAuthentication {
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler({response.project})
                    })
                } else {
                    throw WeLoopError.accessDenied
                }
            } catch (let error) {
                DispatchQueue.main.async(execute: { () -> Void in
                    completionHandler({ throw error})
                })
            }
        })
    }
    
    private func authenticationRequest() -> URLRequest? {
        
        guard let apiKey = apiKey else { return nil }
        
        var urlRequest = URLRequest(url: authenticationURL())
        urlRequest.httpMethod = "POST";
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: ["AutoAuthentication": autoAuthentication, "ProjectGuid": apiKey]) else {
            return nil
        }
        urlRequest.httpBody = httpBody
        return urlRequest
    }
    
    private func authenticationURL() -> URL {
        if let domain = domain {
            return URL(string: "https://\(domain)-api.getweloop.io/api/UnauthorizedData/checkProjectIsVisible")!
        } else {
            return URL(string: "https://api.getweloop.io/api/UnauthorizedData/checkProjectIsVisible")!
        }
    }
    
    func appURL() -> String {
        if let domain = domain {
            return "https://\(domain).getweloop.io/app/plugin/index/#"
        } else {
            return "https://app.getweloop.io/app/plugin/index/#"
        }

    }
}
