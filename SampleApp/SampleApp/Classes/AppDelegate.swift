//
//  AppDelegate.swift
//  SampleApp
//
//  Created by Gentner, Sebastian on 30.09.19.
//  Copyright © 2019 Datagroup Mobile Solutions AG. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = LaunchViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    static func swap(rootViewController: UIViewController) {
        let app = UIApplication.shared
        guard let appDelegate = app.delegate as? AppDelegate else {
            return
        }
        appDelegate.window?.rootViewController = rootViewController
        
    }
}

