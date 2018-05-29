//
//  friendViewController.swift
//  home
//
//  Created by Evans Wu on 2018/5/22.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation
import UIKit
import Quickblox

class FriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GetUserInfoDelegate {

    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!

    var myFriend: [User] = []
    var currentUser: QBUUser?
    let getUserInfoManager = GetUserInfoManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setAddFriendButton()
        getInfo()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addFriendVC = segue.destination as? AddFriendViewController {
            addFriendVC.currentUser = self.currentUser
        } else { } //handle error

        if let checkInviteVC = segue.destination as? CheckInviteViewController {
            checkInviteVC.currentUser = self.currentUser
        } else { } //handle error
    }

    func manager(_ manager: GetUserInfoManager, sender userIDs: [String: NSNumber]) {
    }

    func manager(_ manager: GetUserInfoManager, recipient userIDs: [String: NSNumber]) {
    }

    func manager(_ manager: GetUserInfoManager, didFetch users: [User]) {
        myFriend = users
        friendsTableView.reloadData()
    }

    func manager(_ manager: GetUserInfoManager, didFetch user: User) {

        if user.nickname.isEmpty {
            userName.text = user.login
        } else {
            userName.text = user.nickname
        }
        userImageView.image = #imageLiteral(resourceName: "USERIMAGE")
        friendsTableView.reloadData()
    }

    func manager(_ manager: GetUserInfoManager, error: Error) {
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFriend.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var userCell = UITableViewCell()
        if let cell = friendsTableView.dequeueReusableCell(withIdentifier: "FRIEND_CELL", for: indexPath)
            as? FriendTableViewCell {
            let friend = myFriend[indexPath.row]
            cell.friendImageView.image = #imageLiteral(resourceName: "USERIMAGE")
            cell.friendImageView.layer.masksToBounds = true
            cell.friendImageView.layer.cornerRadius = cell.friendImageView.frame.width/2
            cell.friendNameLabel.numberOfLines = 0
            if friend.nickname.isEmpty {
                cell.friendNameLabel.text = "\(friend.login)"
            } else {
                cell.friendNameLabel.text = "\(friend.nickname)"
            }
            userCell = cell
        } else {  } //handle error
        return userCell
    }
    //點選後的動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = myFriend[indexPath.row]
        print(friend.login)
    }

    func getInfo() {
        if let userInfo = currentUser {
            getUserInfoManager.delegate = self
            getUserInfoManager.getFriend(userID: userInfo.id)
            getUserInfoManager.getUserInfo(userId: userInfo.id)
        } else { return } //handle error
    }

    @objc func goAddFriend() {
        self.performSegue(withIdentifier: "MAKE_FRIEND", sender: nil)
    }

    @objc func goCheckInvite() {
        self.performSegue(withIdentifier: "GO_CHECK_INVITE", sender: nil)
    }

    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    func setAddFriendButton() {
        self.navigationItem.title = "朋友"
        let addFriendButton = UIBarButtonItem()
        addFriendButton.image = #imageLiteral(resourceName: "INVITEFRIEND")
        addFriendButton.target = self
        addFriendButton.action = #selector(goAddFriend)

        let checkInviteButton = UIBarButtonItem()
        checkInviteButton.image = #imageLiteral(resourceName: "CHECKINVITE")
        checkInviteButton.target = self
        checkInviteButton.action = #selector(goCheckInvite)
        self.navigationItem.rightBarButtonItems = [addFriendButton, checkInviteButton]

        let backButton = UIBarButtonItem()
        backButton.image = #imageLiteral(resourceName: "GOOUT")
        backButton.target = self
        backButton.action = #selector(goBack)
        self.navigationItem.leftBarButtonItem = backButton
    }

}
