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

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        WeLoop.setInvocationMethod(.shakeGesture)
        WeLoop.initialize(apiKey: "a8632a59-ab81-456e-a4db-0cd6611ee94d");
        WeLoop.identifyUser(firstName: "Paseuth", lastName: "Thammavong", email: "paseuth.thammavong@weloop.io")
        return true
    }
}
