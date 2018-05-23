//
//  InviteFriendViewController.swift
//  home
//
//  Created by Evans Wu on 2018/5/15.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Quickblox
import QuickbloxWebRTC

class InviteFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GetFriendDelegate {

    var myFriend: [User] = []
    var inviteIds: [NSNumber] = []
    var currentUser: QBUUser?
    weak var delegate: InviteFriendDelegate?
    let getFriendManager = GetFriendManager()
    @IBOutlet weak var inviteFriendTableview: UITableView!
    @IBAction func backToHome(_ sender: UIButton) {
        self.delegate?.manager(self, didFetch: inviteIds)
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getFriend()
    }

    func manager(_ manager: GetFriendManager, didFetch friend: [User]) {
        myFriend = friend
        self.inviteFriendTableview.reloadData()
    }

    func manager(_ manager: GetFriendManager, didFetch user: User) {
    }

    func manager(_ manager: GetFriendManager, error: Error) {
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFriend.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var userCell = UITableViewCell()
        if let cell = inviteFriendTableview.dequeueReusableCell(withIdentifier: "INVITE_CELL", for: indexPath)
            as? InviteFriendTableViewCell {
            let friend = myFriend[indexPath.row]
            cell.userImageView.image = #imageLiteral(resourceName: "USERIMAGE")
            cell.userImageView.layer.masksToBounds = true
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            cell.userNameLabel.numberOfLines = 0
            if friend.nickname.isEmpty {
                cell.userNameLabel.text = "\(friend.login)"
            } else {
                cell.userNameLabel.text = "\(friend.nickname)"
            }
            userCell = cell
        } else {  } //handle error
        return userCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            if let userId = inviteIds.index(of: myFriend[indexPath.row].userID) {
                inviteIds.remove(at: userId)
            } else {
                print("取消時發生錯誤") //handle error
                return
            }
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            inviteIds.append(myFriend[indexPath.row].userID)
        }
    }

    func getFriend() {
        if let  userInfo = currentUser {
            getFriendManager.delegate = self
            getFriendManager.getFriend(userID: userInfo.id)
        } else { return } //handle error
    }

}
