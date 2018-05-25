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

class CheckInviteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GetUserInfoDelegate {

    @IBOutlet weak var checkInviteTableView: UITableView!
    var recipient: [User] = []
    var sender: [User] = []
    let getUserInfoManager = GetUserInfoManager()
    var currentUser: QBUUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserInfoManager.delegate = self

        guard let userID = currentUser?.id else { return } //handle error
        self.getUserInfoManager.checkFriendInvite(userID: userID)

    }

    func manager(_ manager: GetUserInfoManager, sender users: [User]) {
        sender = users
        guard let userID = currentUser?.id else { return } //handle error
        self.getUserInfoManager.delegate = self
        self.getUserInfoManager.checkRecipient(userID: userID)
    }
    func manager(_ manager: GetUserInfoManager, recipient users: [User]) {
        recipient = users
        self.checkInviteTableView.reloadData()
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
            return recipient.count
        } else {
            return sender.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var checkInviteCell = UITableViewCell()
        if let cell = checkInviteTableView.dequeueReusableCell(withIdentifier: "CHECK_INVITE_CELL", for: indexPath) as? CheckInviteTableViewCell {

            if indexPath.section == 0 {
                let checkSender = sender[indexPath.row]
                cell.textLabel?.text = "\(checkSender.login)希望與你成為朋友"
            } else {
                let checkRecipient = recipient[indexPath.row]
                cell.textLabel?.text = checkRecipient.login
            }

            checkInviteCell = cell
        }
        return checkInviteCell
    }
}
