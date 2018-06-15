//
//  AppDelegate.swift
//  FunChat
//
//  Created by Evans Wu on 2018/6/15.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import Firebase
import Fabric

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        
        QBSettings.applicationID = 70678
        QBSettings.authKey = "uFw33nGkcf2vNma"
        QBSettings.authSecret = "44NDcGp2mMZCTOw"
        QBSettings.accountKey = "Ksi1_E7QzA5Hrkc5rsB6"
        QBSettings.autoReconnectEnabled = true
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.180, green: 0.459, blue: 0.733, alpha: 1.00)
        
        return true
    }

}

