//
//  Authentication.swift
//  WeLoop
//
//  Created by Henry Huck on 04/04/2019.
//

import Foundation

/// Flag to switch between production and staging environments. Use for debugging only.
private let isStaging = false

typealias ConfigurationCallback = (_ project:() throws -> Settings) -> Void
typealias NotificationCountCallback = (_ count: () throws  -> NotificationCount) -> Void

// API Methods to communicate with the weLoop API. This is part of the weloop object since their number are limited,
// but should be splitted into a dedicated object if it were to become bigger
extension WeLoop {
    
    // Widget Settings
    
    func widgetConfiguration(completionHandler: @escaping ConfigurationCallback) -> URLSessionDataTask? {
        
        guard let request = configurationRequest() else {
            return nil
        }
        
        return URLSession(configuration: .default).dataTask(with: request, completionHandler: { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw WeLoopError.configurationDataMissing }
                
                let settings = try JSONDecoder().decode(Settings.self, from: data)
                DispatchQueue.main.async(execute: { () -> Void in
                    completionHandler({ settings })
                })
            } catch (let error) {
                DispatchQueue.main.async(execute: { () -> Void in
                    completionHandler({ throw error})
                })
            }
        })
    }
    
    func updateNotificationCount(completionHandler: @escaping NotificationCountCallback) -> URLSessionDataTask? {
        guard let request = notificationCountRequest() else {
            return nil
        }
        
        return URLSession(configuration: .default).dataTask(with: request, completionHandler: { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw WeLoopError.configurationDataMissing }
                
                let count = try JSONDecoder().decode(NotificationCount.self, from: data)
                DispatchQueue.main.async(execute: { () -> Void in
                    completionHandler({ count })
                })
            } catch (let error) {
                DispatchQueue.main.async(execute: { () -> Void in
                    completionHandler({ throw error})
                })
            }
        })    }
    
    private func configurationRequest() -> URLRequest? {
        
        guard let configurationURL = configurationURL else { return nil }
        
        var urlRequest = URLRequest(url: configurationURL)
        urlRequest.httpMethod = "GET";
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    private func notificationCountRequest() -> URLRequest? {
        guard let notificationURL = notificationURL else { return nil }
        
        var urlRequest = URLRequest(url: notificationURL)
        urlRequest.httpMethod = "GET";
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    // Router
    
    private var configurationURL: URL? {
        get {
            guard let apiKey = apiKey else { return nil }
            return URL(string: "\(apiURL)/widget/\(apiKey)")!
        }
    }
    
    private var notificationURL: URL? {
        get {
            guard let apiKey = apiKey, let user = authenticatedUser else { return nil }
            return URL(string: "\(apiURL)/widgetnotifications/count?email=\(user.email)&appGuid=\(apiKey)")!
        }

    }
    
    private var apiURL: String {
        get {
            return isStaging ? "https://staging-api.30kg-rice.cooking" : "https://api.weloop.io"
        }
    }
    
    var appURL: String {
        get {
            return isStaging ? "https://staging-widget.30kg-rice.cooking/home" :  "https://widget.weloop.io/home"
        }
    }
}
