//
//  GetUserInfoManager.swift
//  home
//
//  Created by Evans Wu on 2018/5/21.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class GetUserInfoManager {

    var ref: DatabaseReference?
    weak var delegate: GetUserInfoDelegate?
    var users: [User] = []
    var recipient: [User] = []
    var sender: [User] = []

    func getFriend(userID: UInt) {
        ref = Database.database().reference()
        ref?.child("friend").queryOrdered(byChild: "self").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (snapshoot) in
            guard let data = snapshoot.value as? [String: Any] else { return } //error handle
            for key in data.keys {
                if let friends = data["\(key)"] as? [String: Any] {
                    if let friendID = friends["friend"] as? NSNumber {
                        self.getUsersInfo(userId: friendID)
                    } else { /* error handle */ }
                } else { /* error handle */ }
            }
        })
    }

    func getUsersInfo(userId: NSNumber) {
        ref = Database.database().reference()
        ref?.child("user").queryOrdered(byChild: "id").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshoot) in
            guard let userInfos = snapshoot.value as? [String: Any] else { return } /* error handle */
            for key in userInfos.keys {
                if let userInfo = userInfos["\(key)"] as? [String: Any] {
                    if let email = userInfo["email"] as? String {
                        if let userId = userInfo["id"] as? NSNumber {
                            if let login = userInfo["login"] as? String {
                                if let nickname = userInfo["nickname"] as? String {
                                    self.users.append(User.init(email: email, userID: userId, nickname: nickname, login: login))
                                    self.delegate?.manager(self, didFetch: self.users)
                                } else { /* error handle */ }
                            } else { /* error handle */ }
                        } else { /* error handle */ }
                    } else { /* error handle */ }
                } else { /* error handle */ }
            }
        })
    }

    func getUserInfo(userId: UInt) {
        ref = Database.database().reference()
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
                                } else { /* error handle */ }
                            } else { /* error handle */ }
                        } else { /* error handle */ }
                    } else { /* error handle */ }
                } else { /* error handle */ }
            }
        })
    }

    func addFriendInfo(userLogin: String) {
        ref = Database.database().reference()
        ref?.child("user").queryOrdered(byChild: "login").queryEqual(toValue: userLogin).observeSingleEvent(of: .value, with: { (snapshoot) in
            guard let userInfos = snapshoot.value as? [String: Any] else { return } /* error handle */
            for key in userInfos.keys {
                if let userInfo = userInfos["\(key)"] as? [String: Any] {
                    if let email = userInfo["email"] as? String {
                        if let userId = userInfo["id"] as? NSNumber {
                            if let login = userInfo["login"] as? String {
                                if let nickname = userInfo["nickname"] as? String {
                                    let user = User.init(email: email, userID: userId, nickname: nickname, login: login)
                                    self.delegate?.manager(self, didFetch: user)
                                } else { /* error handle */ }
                            } else { /* error handle */ }
                        } else { /* error handle */ }
                    } else { /* error handle */ }
                } else { /* error handle */ }
            }
        })
    }

    func checkFriendInvite(userID: UInt) {
        ref = Database.database().reference()
        ref?.child("wait").queryOrdered(byChild: "recipient").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (snapshoot) in
            guard let data = snapshoot.value as? [String: Any] else { return } /* error handle */
            for key in data.keys {
                if let wait = data["\(key)"] as? [String: Any] {
                    if let sender = wait["sender"] as? NSNumber {
                        self.getSenderInfo(userId: sender)
                    } else { /* error handle */ }
                } else { /* error handle */ }
            }
        })
    }

    func checkRecipient(userID: UInt) {
        ref = Database.database().reference()
        ref?.child("wait").queryOrdered(byChild: "sender").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (snapshoot) in
            guard let data = snapshoot.value as? [String: Any] else { return } /* error handle */
            for key in data.keys {
                if let wait = data["\(key)"] as? [String: Any] {
                    if let recipient = wait["recipient"] as? NSNumber {
                        self.getRecipientInfo(userId: recipient)
                    } else { /* error handle */ }
                } else { /* error handle */ }
            }
        })
    }

    func getSenderInfo(userId: NSNumber) {
        ref = Database.database().reference()
        ref?.child("user").queryOrdered(byChild: "id").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshoot) in
            guard let userInfos = snapshoot.value as? [String: Any] else { return } /* error handle */
            for key in userInfos.keys {
                if let userInfo = userInfos["\(key)"] as? [String: Any] {
                    if let email = userInfo["email"] as? String {
                        if let userId = userInfo["id"] as? NSNumber {
                            if let login = userInfo["login"] as? String {
                                if let nickname = userInfo["nickname"] as? String {
                                    self.sender.append(User.init(email: email, userID: userId, nickname: nickname, login: login))
                                    self.delegate?.manager(self, sender: self.sender)
                                } else { /* error handle */ }
                            } else { /* error handle */ }
                        } else { /* error handle */ }
                    } else { /* error handle */ }
                } else { /* error handle */ }
            }
        })
    }

    func getRecipientInfo(userId: NSNumber) {
        ref = Database.database().reference()
        ref?.child("user").queryOrdered(byChild: "id").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshoot) in
            guard let userInfos = snapshoot.value as? [String: Any] else { return } /* error handle */
            for key in userInfos.keys {
                if let userInfo = userInfos["\(key)"] as? [String: Any] {
                    if let email = userInfo["email"] as? String {
                        if let userId = userInfo["id"] as? NSNumber {
                            if let login = userInfo["login"] as? String {
                                if let nickname = userInfo["nickname"] as? String {
                                    self.recipient.append(User.init(email: email, userID: userId, nickname: nickname, login: login))
                                    self.delegate?.manager(self, recipient: self.recipient)
                                } else { /* error handle */ }
                            } else { /* error handle */ }
                        } else { /* error handle */ }
                    } else { /* error handle */ }
                } else { /* error handle */ }
            }
        })
    }
}
