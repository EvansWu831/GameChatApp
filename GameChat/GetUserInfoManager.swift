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

enum GetUserInfoManagerError: Error {
    case canNotFindThisID
}

class GetUserInfoManager {

    weak var delegate: GetUserInfoDelegate?
    var reference: DatabaseReference?
    var senderInfos: [User] = []

    func getFriend(userID: UInt) {
        var users: [User] = []
        reference = Database.database().reference()
        let path = reference?.child("relationship").queryOrdered(byChild: "self")
        path?.queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (relationshipData) in
            guard let relationship = relationshipData.value as? [String: Any] else { return } //error handle
            for relationshipAutoKey in relationship.keys {
                if let friends = relationship["\(relationshipAutoKey)"] as? [String: Any] {
                    if let friendID = friends["friend"] as? NSNumber {
                        let friendPath = self.reference?.child("user").queryOrdered(byChild: "id")
                        friendPath?.queryEqual(toValue: friendID).observeSingleEvent(of: .value, with: { (snapshoot) in
                            guard let userInfos = snapshoot.value as? [String: Any] else { return }/* error handle */
                            for key in userInfos.keys {
                                if let userInfo = userInfos["\(key)"] as? [String: Any] {
                                    if let email = userInfo["email"] as? String {
                                        if let userId = userInfo["id"] as? NSNumber {
                                            if let login = userInfo["login"] as? String {
                                                if let nickname = userInfo["nickname"] as? String {
                                                    users.append(User.init(email: email,
                                                                                userID: userId,
                                                                                nickname: nickname,
                                                                                login: login,
                                                                                autoID: relationshipAutoKey))
                                                } else { /* error handle */ }
                                            } else { /* error handle */ }
                                        } else { /* error handle */ }
                                    } else { /* error handle */ }
                                } else { /* error handle */ }
                            }
                            self.delegate?.manager(self, didFetch: users)
                        })
                    } else { /* error handle */ }
                } else { /* error handle */ }
            }
        })
    }

    func getUserInfo(userId: UInt) {
        reference = Database.database().reference()
        let path = reference?.child("user").queryOrdered(byChild: "id")
        path?.queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { (snapshoot) in
            guard let userInfos = snapshoot.value as? [String: Any] else { return } /* error handle */
            for key in userInfos.keys {
                if let userInfo = userInfos["\(key)"] as? [String: Any] {
                    if let email = userInfo["email"] as? String {
                        if let userId = userInfo["id"] as? NSNumber {
                            if let login = userInfo["login"] as? String {
                                if let nickname = userInfo["nickname"] as? String {
                                    let user = User.init(email: email,
                                                         userID: userId,
                                                         nickname: nickname,
                                                         login: login,
                                                         autoID: key)
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
        reference = Database.database().reference()
        let path = reference?.child("user").queryOrdered(byChild: "login")
        path?.queryEqual(toValue: userLogin).observeSingleEvent(of: .value, with: { (snapshoot) in
            guard let userInfos = snapshoot.value as? [String: Any] else {
                self.delegate?.manager(self, error: GetUserInfoManagerError.canNotFindThisID)
                return
            } /* error handle */
            for key in userInfos.keys {
                if let userInfo = userInfos["\(key)"] as? [String: Any] {
                    if let email = userInfo["email"] as? String {
                        if let userId = userInfo["id"] as? NSNumber {
                            if let login = userInfo["login"] as? String {
                                if let nickname = userInfo["nickname"] as? String {
                                    let user = User.init(email: email,
                                                         userID: userId,
                                                         nickname: nickname,
                                                         login: login,
                                                         autoID: key)
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
        reference = Database.database().reference()
        let recipientPath = reference?.child("wait").queryOrdered(byChild: "recipient")

        recipientPath?.queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (snapshoot) in
            if let data = snapshoot.value as? [String: Any] {
                for waitAutoID in data.keys {
                    if let wait = data["\(waitAutoID)"] as? [String: Any] {
                        if let senderID = wait["sender"] as? NSNumber {
                            self.getSendrInfo(senderID: senderID, waitAutoID: waitAutoID)
                        } else { /* error handle */ }
                    } else { /* error handle */ }
                }
            } else {
                self.delegate?.manager(self, sender: self.senderInfos)
            }
        })
    }

    func checkRecipients(userID: UInt) {
        var recipientInfos: [User] = []
        reference = Database.database().reference()
        let senderPath = reference?.child("wait").queryOrdered(byChild: "sender")
        let path = reference?.child("user").queryOrdered(byChild: "id")
        senderPath?.queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (snapshoot) in
            if let data = snapshoot.value as? [String: Any] {
                for waitAutoID in data.keys {
                    if let wait = data["\(waitAutoID)"] as? [String: Any] {
                        if let recipientID = wait["recipient"] as? NSNumber {
                            path?.queryEqual(toValue: recipientID).observe(.value, with: { (recipientUser) in
                                guard let userInfos = recipientUser.value as? [String: Any] else { return } /* error handle */
                                for userAutoKey in userInfos.keys {
                                    if let userInfo = userInfos["\(userAutoKey)"] as? [String: Any] {
                                        if let email = userInfo["email"] as? String {
                                            if let userId = userInfo["id"] as? NSNumber {
                                                if let login = userInfo["login"] as? String {
                                                    if let nickname = userInfo["nickname"] as? String {
                                                        recipientInfos.append(User.init(email: email,
                                                                                             userID: userId,
                                                                                             nickname: nickname,
                                                                                             login: login,
                                                                                             autoID: waitAutoID))
                                                    } else { /* error handle */ }
                                                } else { /* error handle */ }
                                            } else { /* error handle */ }
                                        } else { /* error handle */ }
                                    } else { /* error handle */ }
                                }
                                self.delegate?.manager(self, recipient: recipientInfos)
                            })
                        } else { /* error handle */ }
                    } else { /* error handle */ }
                }
            } else {
                self.delegate?.manager(self, recipient: recipientInfos)
            }
        })
    }

    func getSendrInfo(senderID: NSNumber, waitAutoID: String) {
        reference = Database.database().reference()
        let path = reference?.child("user").queryOrdered(byChild: "id")
        path?.queryEqual(toValue: senderID).observe(.value, with: { (senderUser) in
            guard let userInfos = senderUser.value as? [String: Any] else { return } /* error handle */
            for userAutoKey in userInfos.keys {
                if let userInfo = userInfos["\(userAutoKey)"] as? [String: Any] {
                    if let email = userInfo["email"] as? String {
                        if let userId = userInfo["id"] as? NSNumber {
                            if let login = userInfo["login"] as? String {
                                if let nickname = userInfo["nickname"] as? String {
                                    self.senderInfos.append(User.init(email: email,
                                                                      userID: userId,
                                                                      nickname: nickname,
                                                                      login: login,
                                                                      autoID: waitAutoID))
                                } else { /* error handle */ }
                            } else { /* error handle */ }
                        } else { /* error handle */ }
                    } else { /* error handle */ }
                } else { /* error handle */ }
            }
            self.delegate?.manager(self, sender: self.senderInfos)
        })
    }
}
