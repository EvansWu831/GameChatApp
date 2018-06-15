//
//  User.swift
//  home
//
//  Created by Evans Wu on 2018/5/21.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation
import UIKit

class User {
    let email: String
    let userID: NSNumber
    let nickname: String
    let login: String
    let autoID: String
    init(email: String, userID: NSNumber, nickname: String, login: String, autoID: String) {
        self.email = email
        self.login = login
        self.userID = userID
        self.nickname = nickname
        self.autoID = autoID
    }
}
