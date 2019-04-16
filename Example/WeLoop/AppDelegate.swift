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

    private let autoAuthentication: Bool = false
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set the invocation preferences. You can always change them after invoking the SDK
        WeLoop.set(preferredButtonPosition: .bottomRight)
        WeLoop.set(invocationMethod: .fab)

        if autoAuthentication {
            // Auto Authentication flow
            WeLoop.initialize(apiKey: "a8632a59-ab81-456e-a4db-0cd6611ee94d");
            WeLoop.identifyUser(firstName: "Paseuth", lastName: "Thammavong", email: "paseuth.thammavong@weloop.io")
        } else {
            // Manual Authentication flow
            WeLoop.initialize(apiKey: "a8632a59-ab81-456e-a4db-0cd6611ee94d", autoAuthentication: false);
            // No need to call identify user
        }
        
        return true
    }
}
