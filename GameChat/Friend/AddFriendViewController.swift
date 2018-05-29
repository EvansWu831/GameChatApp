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
    var newFriend: User?
    let getUserInfoManager = GetUserInfoManager()
    var ref: DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        infoView.isHidden = true
        addButton.isHidden = true
        sendButton.addTarget(self, action: #selector(searchUser), for: UIControlEvents.touchUpInside)
        addButton.addTarget(self, action: #selector(addNewFriend), for: UIControlEvents.touchUpInside)
        userImageView.image = #imageLiteral(resourceName: "USERIMAGE")
        setGoBackButton()
    }

    func manager(_ manager: GetUserInfoManager, sender userIDs: [String: NSNumber]) {
    }

    func manager(_ manager: GetUserInfoManager, recipient userIDs: [String: NSNumber]) {
    }

    func manager(_ manager: GetUserInfoManager, didFetch users: [User]) {
    }

    func manager(_ manager: GetUserInfoManager, didFetch user: User) {

        newFriend = user
        setUserInfo()
        checkRelationship()
    }

    func manager(_ manager: GetUserInfoManager, error: Error) {
        if let error = error as? GetUserInfoManagerError {

            switch error {
            case .canNotFindThisID:
                infoView.isHidden = true
                let alert = UIAlertController(title: nil, message: "查無此ID", preferredStyle: .alert)
                let action = UIAlertAction(title: "確定", style: .default)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        } else { print("未知錯誤") }
    }

    func setUserInfo() {

        if let userInfo = newFriend {
            infoView.isHidden = false
            addButton.isHidden = false
            userImageView.image = #imageLiteral(resourceName: "USERIMAGE")
            if userInfo.nickname.isEmpty {
                userNameLabel.text = userInfo.login
            } else {
                userNameLabel.text = userInfo.nickname
            }
        } else {} //handle error
    }

    @objc func searchUser() {
        if let userName = searchTextField.text {
            if !userName.isEmpty {
                if userName != currentUser?.login {
                    getUserInfoManager.delegate = self
                    getUserInfoManager.addFriendInfo(userLogin: userName)
                } else {
                    infoView.isHidden = true
                    let alert = UIAlertController(title: nil, message: "在尋找自己嗎？", preferredStyle: .alert)
                    let action = UIAlertAction(title: "確定", style: .default)
                    alert.addAction(action)
                    present(alert, animated: true, completion: nil)
                } //handle error
            } else {print("userName空白") } //handle error
        } else { print("userName空") } //handle error
    }

    @objc func addNewFriend() {
        guard let user = currentUser else {return} //handle error
        guard let new = newFriend else {return} //handle error
        ref = Database.database().reference()
        ref?.child("wait").childByAutoId().setValue(["sender": user.id, "recipient": new.userID])
        
    }

    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    func setGoBackButton() {
        let backButton = UIBarButtonItem()
        backButton.image = #imageLiteral(resourceName: "GOOUT")
        backButton.target = self
        backButton.action = #selector(goBack)
        self.navigationItem.leftBarButtonItem = backButton
    }

    func checkRelationship() {
        guard let user = currentUser else {return} //handle error
        guard let new = newFriend else {return} //handle error
        ref = Database.database().reference()
        ref?.child("relationship").queryOrdered(byChild: "self").queryEqual(toValue: user.id).observeSingleEvent(of: .value, with: { (snapshot) in
            if let friends = snapshot.value as? [String: Any] {
                for key in friends.keys {
                    if let relationship = friends["\(key)"] as? [String: Any] {
                        if let friendID = relationship["friend"] as? NSNumber {
                            if new.userID == friendID {
                                self.addButton.isHidden = true
                                let alert = UIAlertController(title: nil, message: "已經是朋友了", preferredStyle: .actionSheet)
                                let action = UIAlertAction(title: "確定", style: .default)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                            } else {} //handle error
                        } else {} //handle error
                    } else {} //handle error
                }
            } else {} //handle error
        })
    }
}
