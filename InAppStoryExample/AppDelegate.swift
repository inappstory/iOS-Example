//
//  AppDelegate.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // replace "<service_key>" with the key obtained in the console
        InAppStory.shared.initWith(serviceKey: "<service_key>")
        
        let navigationController = UINavigationController(rootViewController: MainTableController())
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}
