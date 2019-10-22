//
//  AppDelegate.swift
//  openLiveDemo
//
//  Created by 寇松涛 on 2019/9/29.
//  Copyright © 2019 寇松涛. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//         Override point for customization after application launch.
        window = UIWindow.init(frame: UIScreen.main.bounds)
        let rootVc = ViewController()
        window?.rootViewController = UINavigationController.init(rootViewController: rootVc)
        window?.makeKeyAndVisible()
        return true
    }

}

