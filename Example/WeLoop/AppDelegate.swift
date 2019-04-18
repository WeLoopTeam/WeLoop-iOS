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

    // Change this setting to test between autoAuthentication and manual Authentication
    private let autoAuthentication: Bool = true
    
    // This is a fake project GUID. Replace it with your actual project ID to test the example
    private let projectGUID = "12345678-abcd-efgh-l33t-123456789abc"
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set the invocation preferences. You can always change them after invoking the SDK
        WeLoop.set(preferredButtonPosition: .bottomRight)
        WeLoop.set(invocationMethod: .fab)
        
        WeLoop.set(delegate: self)

        if autoAuthentication {
            // Auto Authentication flow
            WeLoop.initialize(apiKey: projectGUID, autoAuthentication: true);
            WeLoop.identifyUser(firstName: "John", lastName: "Doe", email: "john.doe@weloop.io")
        } else {
            // Manual Authentication flow
            WeLoop.initialize(apiKey: projectGUID, autoAuthentication: false);
            // No need to call identify user
        }
        
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
