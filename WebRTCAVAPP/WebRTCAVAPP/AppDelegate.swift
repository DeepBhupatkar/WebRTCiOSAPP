//
//  AppDelegate.swift
//  WebRTCAVAPP
//
//  Created by DEEP BHUPATKAR on 22/06/24.
//

import UIKit

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize the window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Load the correct storyboard
        let storyboard = UIStoryboard(name: "MainViewController", bundle: nil)
        
        // Instantiate the initial view controller from storyboard using its identifier
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController")
        
        // Set the root view controller of the window
        window?.rootViewController = initialViewController
        
        // Make the window visible
        window?.makeKeyAndVisible()
        
        return true
    }

    // Other methods if needed
    
}
