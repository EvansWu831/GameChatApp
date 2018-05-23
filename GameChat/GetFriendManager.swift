//
//  getFriendManager.swift
//  home
//
//  Created by Evans Wu on 2018/5/21.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class GetFriendManager {

    var ref: DatabaseReference?
    weak var delegate: GetFriendDelegate?
    var frineds: [User] = []

    func getFriend(userID: UInt) {
        ref = Database.database().reference()
        ref?.child("friend").queryOrdered(byChild: "self").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (snapshoot) in
            guard let data = snapshoot.value as? [String: Any] else { return } //error handle
            for key in data.keys {
                if let friends = data["\(key)"] as? [String: Any] {
                    if let friendID = friends["friend"] as? NSNumber {
                        self.getFriendInfo(userId: friendID)
                    } else { /* error handle */ }
                } else { /* error handle */ }
            }
        })
    }

    func getFriendInfo(userId: NSNumber) {
        ref?.child("user").queryOrdered(byChild: "id").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshoot) in
            guard let userInfos = snapshoot.value as? [String: Any] else { return } /* error handle */
            for key in userInfos.keys {
                if let userInfo = userInfos["\(key)"] as? [String: Any] {
                    if let email = userInfo["email"] as? String {
                        if let userId = userInfo["id"] as? NSNumber {
                            if let login = userInfo["login"] as? String {
                                if let nickname = userInfo["nickname"] as? String {
                                    self.frineds.append(User.init(email: email, userID: userId, nickname: nickname, login: login))
                                    self.delegate?.manager(self, didFetch: self.frineds)
                                } else {}
                            } else {}
                        } else {}
                    } else {}
                } else {}
            }
        })
    }

    func getUserInfo(userId: UInt) {
        ref?.child("user").queryOrdered(byChild: "id").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshoot) in
            guard let userInfos = snapshoot.value as? [String: Any] else { return } /* error handle */
            for key in userInfos.keys {
                if let userInfo = userInfos["\(key)"] as? [String: Any] {
                    if let email = userInfo["email"] as? String {
                        if let userId = userInfo["id"] as? NSNumber {
                            if let login = userInfo["login"] as? String {
                                if let nickname = userInfo["nickname"] as? String {
                                    let user = User.init(email: email, userID: userId, nickname: nickname, login: login)
                                    self.delegate?.manager(self, didFetch: user)
                                } else {}
                            } else {}
                        } else {}
                    } else {}
                } else {}
            }
        })
    }
}
