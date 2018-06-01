//
//  GetFrinedDelegate.swift
//  home
//
//  Created by Evans Wu on 2018/5/21.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation

protocol GetUserInfoDelegate: class {
    func manager(_ manager: GetUserInfoManager, sender users: [User])
    func manager(_ manager: GetUserInfoManager, recipient users: [User])
    func manager(_ manager: GetUserInfoManager, didFetch users: [User])
    func manager(_ manager: GetUserInfoManager, didFetch user: User)
    func manager(_ manager: GetUserInfoManager, error: Error)
}
