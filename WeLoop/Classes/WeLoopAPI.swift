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

struct NotificationResponse: Decodable {
    let success: Bool
    let isNotif: Bool
    
    private enum CodingKeys: String, CodingKey {
        case isNotif = "IsNotif"
        case success = "success"
    }
}

typealias AuthenticationCallback = (_ project:() throws -> Project) -> Void
typealias NotificationCallback = (_ notification:() throws -> NotificationResponse) -> Void

// API Methods to communicate with the weLoop API. This is part of the weloop object since their number are limited,
// but should be splitted into a dedicated object if it were to become bigger
extension WeLoop {
    
    // Authentication
    
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
        
        var urlRequest = URLRequest(url: authenticationURL)
        urlRequest.httpMethod = "POST";
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: ["AutoAuthentication": autoAuthentication, "ProjectGuid": apiKey]) else {
            return nil
        }
        urlRequest.httpBody = httpBody
        return urlRequest
    }
    
    // Notification Refresh
    
    func refreshNotificationCount(completionHandler: @escaping NotificationCallback) {
        guard let request = refreshNotificationCountRequest() else {
            return
        }
        
        let task = URLSession(configuration: .default).dataTask(with: request, completionHandler: { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw WeLoopError.notificationDataMissing }
                let response = try JSONDecoder().decode(NotificationResponse.self, from: data)
                DispatchQueue.main.async(execute: { () -> Void in
                    completionHandler({ response })
                })
            } catch (let error) {
                DispatchQueue.main.async(execute: { () -> Void in
                    completionHandler({ throw error})
                })
            }
        })
        task.resume()
    }
    
    private func refreshNotificationCountRequest() -> URLRequest? {
        guard let notificationURL = notificationURL else { return nil }
        var urlRequest = URLRequest(url: notificationURL)
        urlRequest.httpMethod = "GET";
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    // Router
    
    private var authenticationURL: URL {
        return URL(string: "\(apiURL)/UnauthorizedData/checkProjectIsVisible")!
    }
    
    private var notificationURL: URL? {
        get {
            guard let email = user?.email,  let apiKey = apiKey else { return nil }
            return URL(string: "\(apiURL)/UnauthorizedData/Notif?email=\(email)&projectGuid=\(apiKey)")!
        }
    }
    
    private var apiURL: String {
        get {
            if let subdomain = subdomain {
                return "https://\(subdomain)-api.getweloop.io/api"
            } else {
                return "https://api.getweloop.io/api"
            }
        }
    }
    
    var appURL: String {
        get {
            if let subdomain = subdomain {
                return "https://\(subdomain).getweloop.io/app/plugin/index/#"
            } else {
                return "https://app.getweloop.io/app/plugin/index/#"
            }
            
        }
    }
}
