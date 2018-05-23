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

class FriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GetFriendDelegate {

    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!

    var myFriend: [User] = []
    var currentUser: QBUUser?
    let getFriendManager = GetFriendManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
    }

    func manager(_ manager: GetFriendManager, didFetch friend: [User]) {
        myFriend = friend
        friendsTableView.reloadData()
    }

    func manager(_ manager: GetFriendManager, didFetch user: User) {

        if user.nickname.isEmpty {
            userName.text = user.login
        } else {
            userName.text = user.nickname
        }
        userImageView.image = #imageLiteral(resourceName: "USERIMAGE")
        friendsTableView.reloadData()
    }

    func manager(_ manager: GetFriendManager, error: Error) {
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
            getFriendManager.delegate = self
            getFriendManager.getFriend(userID: userInfo.id)
            getFriendManager.getUserInfo(userId: userInfo.id)
        } else { return } //handle error
    }
}
