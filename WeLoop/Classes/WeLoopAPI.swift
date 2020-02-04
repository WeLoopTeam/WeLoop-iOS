//
//  Authentication.swift
//  WeLoop
//
//  Created by Henry Huck on 04/04/2019.
//

import Foundation

struct NotificationResponse: Decodable {
    let success: Bool
    let isNotif: Bool
    
    private enum CodingKeys: String, CodingKey {
        case isNotif = "IsNotif"
        case success = "success"
    }
}

typealias ConfigurationCallback = (_ project:() throws -> Settings) -> Void
typealias NotificationCallback = (_ notification:() throws -> NotificationResponse) -> Void

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
    
    private func configurationRequest() -> URLRequest? {
        
        guard let configurationURL = configurationURL else { return nil }
        
        var urlRequest = URLRequest(url: configurationURL)
        urlRequest.httpMethod = "GET";
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
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
    
    private var configurationURL: URL? {
        get {
            guard let apiKey = apiKey else { return nil }
            return URL(string: "\(apiURL)/widget/\(apiKey)")!
        }
    }
        
    private var notificationURL: URL? {
        get {
            guard  let apiKey = apiKey else { return nil }
            return URL(string: "\(apiURL)/UnauthorizedData/Notif?projectGuid=\(apiKey)")!
        }
    }
    
    private var apiURL: String {
        get {
           return "https://api.weloop.io"
        }
    }
    
    var appURL: String {
        get {
            return "https://widget.weloop.io/home"
        }
    }
}
