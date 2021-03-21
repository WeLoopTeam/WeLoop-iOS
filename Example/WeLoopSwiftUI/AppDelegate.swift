//
//  AppDelegate.swift
//  WeLoopSwiftUI
//
//  Created by Henry Huck on 06/12/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import WeLoop

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // This is a fake project GUID. Replace it with your actual project ID to test the example
    private let projectGUID = "e19340c0-b453-11e9-8113-1d4bacf0614e"
    private let user = User(id: "1", email: "test1@yopmail.com", firstName: "test1", lastName: "test2")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        WeLoop.set(sceneBasedApplication: true)
                
        // Set the invocation preferences. You can always change them after invoking the SDK
        WeLoop.set(invocationMethod: .manual)

        WeLoop.set(delegate: self)
        WeLoop.initialize(apiKey: projectGUID);
        WeLoop.authenticateUser(user: user)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}


extension AppDelegate: WeLoopDelegate {
    
    func initializationSuccessful() {
        // From this point forward, we can safely invoke the Widget manually
    }
    
    func initializationFailed(with error: Error) {
        // Initialization Failed (no network for example). Based on the error you'll have to retry the initialization later.
        print(error)
    }
    
    func failedToLaunch(with error: Error) {
        // The widget could not be launched. Most likely is that the initialization process failed, or the user is missing in autoAuthentication
        print(error)
    }
    
    func notificationCountUpdated(newCount: Int) {
        print(newCount)
    }
}

