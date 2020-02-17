//
//  AppDelegate.swift
//  WeLoop
//
//  Created by HHK1 on 04/04/2019.
//  Copyright (c) 2019 HHK1. All rights reserved.
//

import UIKit
import WeLoop

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // This is a fake project GUID. Replace it with your actual project ID to test the example
    private let projectGUID = "e19340c0-b453-11e9-8113-1d4bacf0614e"
    private let user = User(id: "1", email: "test1@yopmail.com", firstName: "test1", lastName: "test2")
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
        // Set the invocation preferences. You can always change them after invoking the SDK
        WeLoop.set(invocationMethod: .fab)
        
        WeLoop.set(delegate: self)
        WeLoop.initialize(apiKey: projectGUID);
        WeLoop.authenticateUser(user: user)
        

        return true
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
}
