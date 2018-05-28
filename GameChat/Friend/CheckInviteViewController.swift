//
//  CheckInviteViewController.swift
//  GameChat
//
//  Created by Evans Wu on 2018/5/24.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation
import UIKit
import Quickblox
import Firebase

class CheckInviteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GetUserInfoDelegate {

    @IBOutlet weak var checkInviteTableView: UITableView!
    var recipient: [User] = []
    var sender: [User] = []
    let getUserInfoManager = GetUserInfoManager()
    var currentUser: QBUUser?
    var ref: DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserInfoManager.delegate = self
        guard let userID = currentUser?.id else { return } //handle error
        self.getUserInfoManager.checkFriendInvite(userID: userID)
        setGoBackButton()
    }

    func manager(_ manager: GetUserInfoManager, sender userIDs: [NSNumber]) {

        ref = Database.database().reference()
        for userID in userIDs {
            ref?.child("user").queryOrdered(byChild: "id").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (snapshoot) in
                guard let userInfos = snapshoot.value as? [String: Any] else { return } /* error handle */
                for key in userInfos.keys {
                    if let userInfo = userInfos["\(key)"] as? [String: Any] {
                        if let email = userInfo["email"] as? String {
                            if let userId = userInfo["id"] as? NSNumber {
                                if let login = userInfo["login"] as? String {
                                    if let nickname = userInfo["nickname"] as? String {
                                        self.sender.append(User.init(email: email, userID: userId, nickname: nickname, login: login))
                                    } else { /* error handle */ }
                                } else { /* error handle */ }
                            } else { /* error handle */ }
                        } else { /* error handle */ }
                    } else { /* error handle */ }
                }
            })
        }
        self.getUserInfoManager.delegate = self
        guard let userID = currentUser?.id else { return } //handle error
        self.getUserInfoManager.checkRecipient(userID: userID)
    }

    func manager(_ manager: GetUserInfoManager, recipient userIDs: [NSNumber]) {

        ref = Database.database().reference()
        for userID in userIDs {
            ref?.child("user").queryOrdered(byChild: "id").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (snapshoot) in
                guard let userInfos = snapshoot.value as? [String: Any] else { return } /* error handle */
                for key in userInfos.keys {
                    if let userInfo = userInfos["\(key)"] as? [String: Any] {
                        if let email = userInfo["email"] as? String {
                            if let userId = userInfo["id"] as? NSNumber {
                                if let login = userInfo["login"] as? String {
                                    if let nickname = userInfo["nickname"] as? String {
                                        self.recipient.append(User.init(email: email, userID: userId, nickname: nickname, login: login))
                                        self.checkInviteTableView.reloadData()
                                    } else { /* error handle */ }
                                } else { /* error handle */ }
                            } else { /* error handle */ }
                        } else { /* error handle */ }
                    } else { /* error handle */ }
                }
            })
        }

    }

    func manager(_ manager: GetUserInfoManager, didFetch users: [User]) {
    }

    func manager(_ manager: GetUserInfoManager, didFetch user: User) {
    }

    func manager(_ manager: GetUserInfoManager, error: Error) {
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return sender.count
        } else {
            return recipient.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var checkInviteCell = UITableViewCell()
        if let cell = checkInviteTableView.dequeueReusableCell(withIdentifier: "CHECK_INVITE_CELL", for: indexPath) as? CheckInviteTableViewCell {

            if indexPath.section == 0 {
                let checkSender = sender[indexPath.row]
                cell.userName.text = checkSender.login
                cell.yesButton.addTarget(self, action: #selector(addRelationship), for: .touchUpInside)
            } else {
                let checkRecipient = recipient[indexPath.row]
                cell.userName.text = checkRecipient.login
                cell.yesButton.isHidden = true
            }

            checkInviteCell = cell
        }
        return checkInviteCell
    }

    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func addRelationship() {
        ref = Database.database().reference()
    }

    func setGoBackButton() {
        let backButton = UIBarButtonItem()
        backButton.image = #imageLiteral(resourceName: "GOOUT")
        backButton.target = self
        backButton.action = #selector(goBack)
        self.navigationItem.leftBarButtonItem = backButton
    }
}
