//
//  AppDelegate.swift
//  AirplayNativeIOS
//
//  Created by Human on 5/30/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // IMP
        application.beginReceivingRemoteControlEvents()
        return true
    }

}

