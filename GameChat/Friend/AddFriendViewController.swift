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
import FirebaseStorage

class AddFriendViewController: UIViewController, GetUserInfoDelegate, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    var currentUser: QBUUser?
    var invitees: User?
    let getUserInfoManager = GetUserInfoManager()
    var reference: DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        infoView.isHidden = true
        addButton.isHidden = true
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.width/2

        sendButton.addTarget(self, action: #selector(searchUser), for: UIControlEvents.touchUpInside)
        addButton.addTarget(self, action: #selector(addNewFriend), for: UIControlEvents.touchUpInside)
        userImageView.image = #imageLiteral(resourceName: "USERIMAGE")
        setGoBackButton()
    }

    func manager(_ manager: GetUserInfoManager, sender users: [User]) {
    }

    func manager(_ manager: GetUserInfoManager, recipient users: [User]) {
    }

    func manager(_ manager: GetUserInfoManager, didFetch users: [User]) {
    }

    func manager(_ manager: GetUserInfoManager, didFetch user: User) {

        invitees = user
        setUserInfo()
        checkRelationship()
        checkInvitees()
        checkInvited()
    }

    func manager(_ manager: GetUserInfoManager, error: Error) {
        if let error = error as? GetUserInfoManagerError {

            switch error {
            case .canNotFindThisID:
                infoView.isHidden = true
                let alert = UIAlertController(title: "查無此ID", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "確定", style: .default)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        } else { print("未知錯誤") }
    }

    func setUserInfo() {

        if let userInfo = invitees {
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
                    let alert = UIAlertController(title: "在尋找自己嗎？", message: nil, preferredStyle: .alert)
                    let action = UIAlertAction(title: "確定", style: .default)
                    alert.addAction(action)
                    present(alert, animated: true, completion: nil)
                } //handle error
            } else {print("userName空白") } //handle error
        } else { print("userName空") } //handle error
    }

    @objc func addNewFriend() {
        guard let userID = currentUser?.id else {return} //handle error
        guard let inviteesID = invitees?.userID else {return} //handle error
        reference = Database.database().reference()
        reference?.child("wait").childByAutoId().setValue(["sender": userID, "recipient": inviteesID])
        addButton.isHidden = true
    }

    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    func setGoBackButton() {
        let backButton = UIBarButtonItem()
        backButton.image = #imageLiteral(resourceName: "GO_BACK")
        backButton.target = self
        backButton.action = #selector(goBack)
        self.navigationItem.leftBarButtonItem = backButton
    }

    func checkRelationship() {
        guard let user = currentUser else {return} //handle error
        guard let inviteesID = invitees?.userID else {return} //handle error
        reference = Database.database().reference()
        let path = reference?.child("relationship").queryOrdered(byChild: "self")
        path?.queryEqual(toValue: user.id).observeSingleEvent(of: .value, with: { (snapshot) in
            if let friends = snapshot.value as? [String: Any] {
                for key in friends.keys {
                    if let relationship = friends["\(key)"] as? [String: Any] {
                        if let friendID = relationship["friend"] as? NSNumber {
                            if inviteesID == friendID {
                                self.addButton.isHidden = true
                                let alert = UIAlertController(title: "已經是朋友了", message: nil, preferredStyle: .alert)
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

    func checkInvitees() {
        guard let user = currentUser else {return} //handle error
        guard let inviteesID = invitees?.userID else {return} //handle error
        reference = Database.database().reference()
        let path = reference?.child("wait").queryOrdered(byChild: "sender")
        path?.queryEqual(toValue: user.id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let wait = snapshot.value as? [String: Any] else { return } //handle error
            for key in wait.keys {
                if let relationship = wait["\(key)"] as? [String: Any] {
                    if let recipient = relationship["recipient"] as? NSNumber {
                        if inviteesID == recipient {
                            self.addButton.isHidden = true
                            let alert = UIAlertController(title: "已送出邀請", message: nil, preferredStyle: .alert)
                            let action = UIAlertAction(title: "確定", style: .default)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {} //handle error
                } else {} //handle error
            }
        })
    }

    func checkInvited() {
        guard let userID = currentUser?.id else {return} //handle error
        guard let inviteesID = invitees?.userID else {return} //handle error
        reference = Database.database().reference()
        let path = reference?.child("wait").queryOrdered(byChild: "recipient")
        path?.queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let wait = snapshot.value as? [String: Any] else { return } //handle error
            for key in wait.keys {
                if let relationship = wait["\(key)"] as? [String: Any] {
                    if let recipient = relationship["sender"] as? NSNumber {
                        if inviteesID == recipient {
                            self.addButton.isHidden = true
                            let alert = UIAlertController(title: "等待您確認好友中",
                                                          message: nil,
                                                          preferredStyle: .alert)
                            let action = UIAlertAction(title: "確定", style: .default)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {} //handle error
                } else {} //handle error
            }
        })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
