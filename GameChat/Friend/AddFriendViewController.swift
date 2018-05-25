//
//  MakeFriendViewController.swift
//  GameChat
//
//  Created by Evans Wu on 2018/5/23.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Quickblox

class AddFriendViewController: UIViewController, GetUserInfoDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    var currentUser: QBUUser?
    var newFriend: NSNumber?
    let getUserInfoManager = GetUserInfoManager()
    var ref: DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.addTarget(self, action: #selector(searchUser), for: UIControlEvents.touchUpInside)
        addButton.addTarget(self, action: #selector(addNewFriend), for: UIControlEvents.touchUpInside)
        userImageView.image = #imageLiteral(resourceName: "USERIMAGE")
    }

    func manager(_ manager: GetUserInfoManager, sender users: [User]) {}
    func manager(_ manager: GetUserInfoManager, recipient users: [User]) {}
    func manager(_ manager: GetUserInfoManager, didFetch users: [User]) {
    }

    func manager(_ manager: GetUserInfoManager, didFetch user: User) {
        newFriend = user.userID
        userNameLabel.text = user.nickname
    }

    func manager(_ manager: GetUserInfoManager, error: Error) {
    }

    @objc func searchUser() {
        if let userName = searchTextField.text {
            if !userName.isEmpty {
                getUserInfoManager.delegate = self
                getUserInfoManager.addFriendInfo(userLogin: userName)
            } else {print("userName空白") } //handle error
        } else { print("userName空") } //handle error
    }

    @objc func addNewFriend() {
        guard let user = currentUser else {return} //handle error
        guard let new = newFriend else {return} //handle error
        ref = Database.database().reference()
        ref?.child("wait").childByAutoId().setValue(["sender": user.id, "recipient": new])
    }

}
