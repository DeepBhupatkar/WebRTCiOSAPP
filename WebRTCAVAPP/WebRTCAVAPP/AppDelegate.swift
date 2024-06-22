//
//  AppDelegate.swift
//  WebRTCAVAPP
//
//  Created by DEEP BHUPATKAR on 22/06/24.
//

import UIKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    internal var window: UIWindow?
    private let config = Config.default
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // No need to set up the initial view controller here as it will be done in SceneDelegate.
        return true
    }
}


