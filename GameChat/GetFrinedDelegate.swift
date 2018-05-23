//
//  GetFrinedDelegate.swift
//  home
//
//  Created by Evans Wu on 2018/5/21.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation

protocol GetFriendDelegate: class {
    func manager(_ manager: GetFriendManager, didFetch friend: [User])
    func manager(_ manager: GetFriendManager, didFetch user: User)
    func manager(_ manager: GetFriendManager, error: Error)
}
