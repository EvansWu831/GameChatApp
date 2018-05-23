//
//  AppDelegate.swift
//  GameChat
//
//  Created by Evans Wu on 2018/5/23.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var session: QBRTCSession?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        QBSettings.applicationID = 70678
        QBSettings.authKey = "uFw33nGkcf2vNma"
        QBSettings.authSecret = "44NDcGp2mMZCTOw"
        QBSettings.accountKey = "Ksi1_E7QzA5Hrkc5rsB6"
        QBSettings.autoReconnectEnabled = true

        return true
    }
}
