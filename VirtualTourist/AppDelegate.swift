//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Arch Studios on 6/25/19.
//  Copyright © 2019 AS. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DataController.shared.load()
        return true
    }

    
    func applicationDidEnterBackground(_ application: UIApplication) {
        try? DataController.shared.context.save()
    }

   
    func applicationWillTerminate(_ application: UIApplication) {
        try? DataController.shared.context.save()
    }


}

