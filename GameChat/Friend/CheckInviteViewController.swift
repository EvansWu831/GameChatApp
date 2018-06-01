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
import FirebaseStorage

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
        self.getUserInfoManager.checkRecipient(userID: userID)
        setGoBackButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    func manager(_ manager: GetUserInfoManager, sender userIDs: [String: NSNumber]) {

        ref = Database.database().reference()
        for (autoKey, senderID) in userIDs {
            ref?.child("user").queryOrdered(byChild: "id").queryEqual(toValue: senderID).observeSingleEvent(of: .value, with: { (snapshoot) in
                guard let userInfos = snapshoot.value as? [String: Any] else { return } /* error handle */
                for key in userInfos.keys {
                    if let userInfo = userInfos["\(key)"] as? [String: Any] {
                        if let email = userInfo["email"] as? String {
                            if let userId = userInfo["id"] as? NSNumber {
                                if let login = userInfo["login"] as? String {
                                    if let nickname = userInfo["nickname"] as? String {
                                        self.sender.append(User.init(email: email, userID: userId, nickname: nickname, login: login, autoID: autoKey))
                                    } else { /* error handle */ }
                                } else { /* error handle */ }
                            } else { /* error handle */ }
                        } else { /* error handle */ }
                    } else { /* error handle */ }
                }
                self.checkInviteTableView.reloadData()
            })
        }
    }

    func manager(_ manager: GetUserInfoManager, recipient userIDs: [String: NSNumber]) {

        ref = Database.database().reference()
        for (autoKey, recipientID) in userIDs {
            ref?.child("user").queryOrdered(byChild: "id").queryEqual(toValue: recipientID).observeSingleEvent(of: .value, with: { (snapshoot) in
                guard let userInfos = snapshoot.value as? [String: Any] else { return } /* error handle */
                for key in userInfos.keys {
                    if let userInfo = userInfos["\(key)"] as? [String: Any] {
                        if let email = userInfo["email"] as? String {
                            if let userId = userInfo["id"] as? NSNumber {
                                if let login = userInfo["login"] as? String {
                                    if let nickname = userInfo["nickname"] as? String {
                                        self.recipient.append(User.init(email: email, userID: userId, nickname: nickname, login: login, autoID: autoKey))
                                    } else { /* error handle */ }
                                } else { /* error handle */ }
                            } else { /* error handle */ }
                        } else { /* error handle */ }
                    } else { /* error handle */ }
                }
                self.checkInviteTableView.reloadData()
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
        print(indexPath)
        if let cell = checkInviteTableView.dequeueReusableCell(withIdentifier: "CHECK_INVITE_CELL", for: indexPath) as? CheckInviteTableViewCell {

            cell.noButton.removeTarget(self, action: #selector(refuse(send:)), for: .touchUpInside)
            cell.noButton.removeTarget(self, action: #selector(cancel(send:)), for: .touchUpInside)
            cell.noButton.tintColor = UIColor.red

            cell.userImageView.layer.masksToBounds = true
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2

            if indexPath.section == 0 {
                let checkSender = sender[indexPath.row]

                if checkSender.nickname.isEmpty {
                    cell.userName.text = checkSender.login
                } else {
                    cell.userName.text = checkSender.nickname
                }

                cell.yesButton.setImage(#imageLiteral(resourceName: "ACCEPT"), for: .normal)
                cell.yesButton.isHidden = false
                cell.yesButton.addTarget(self, action: #selector(addRelationship(send:)), for: .touchUpInside)
                cell.noButton.setImage(#imageLiteral(resourceName: "REFUSE"), for: .normal)
                cell.noButton.addTarget(self, action: #selector(refuse(send:)), for: .touchUpInside)

                let storageRef = Storage.storage().reference(withPath: "\(checkSender.userID)/userImage.jpg")
                storageRef.getData(maxSize: 1*1000*1000) { (data, _) in
                    if let image = data {
                        cell.userImageView.image = UIImage(data: image)
                    } else {
                        cell.userImageView.image = #imageLiteral(resourceName: "USERIMAGE")
                    }
                }

            } else {
                let checkRecipient = recipient[indexPath.row]

                if checkRecipient.nickname.isEmpty {
                    cell.userName.text = checkRecipient.login
                } else {
                    cell.userName.text = checkRecipient.nickname
                }

                cell.yesButton.isHidden = true
                cell.noButton.setImage(#imageLiteral(resourceName: "REFUSE"), for: .normal)
                cell.noButton.addTarget(self, action: #selector(cancel(send:)), for: .touchUpInside)

                let storageRef = Storage.storage().reference(withPath: "\(checkRecipient.userID)/userImage.jpg")
                storageRef.getData(maxSize: 1*1000*1000) { (data, _) in
                    if let image = data {
                        cell.userImageView.image = UIImage(data: image)
                    } else {
                        cell.userImageView.image = #imageLiteral(resourceName: "USERIMAGE")
                    }
                }
            }
            checkInviteCell = cell
        }
        return checkInviteCell
    }

    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func addRelationship(send: Any) {
        guard let button = send as? UIButton else { return } //handle error
        guard let contentView = button.superview else { return } //handle error
        guard let cell = contentView.superview as? UITableViewCell else { return } //handle error
        guard let indexPath = checkInviteTableView.indexPath(for: cell) else { return } //handle error
        guard let currentUserID = currentUser?.id else { return } //handle error
        let senderID = sender[indexPath.row].userID
        let autoID = sender[indexPath.row].autoID
        ref = Database.database().reference()
        ref?.child("relationship").childByAutoId().setValue(["friend": senderID, "self": currentUserID])
        ref?.child("relationship").childByAutoId().setValue(["friend": currentUserID, "self": senderID])
        ref?.child("wait").child("\(autoID)").removeValue()
        sender.remove(at: indexPath.row)
        self.checkInviteTableView.reloadData()
    }

    @objc func refuse(send: Any) {
        guard let button = send as? UIButton else { return }
        guard let contentView = button.superview else { return }
        guard let cell = contentView.superview as? UITableViewCell else { return }
        guard let indexPath = checkInviteTableView.indexPath(for: cell) else { return }
        let autoID = sender[indexPath.row].autoID
        ref = Database.database().reference()
        ref?.child("wait").child("\(autoID)").removeValue()
        sender.remove(at: indexPath.row)
        self.checkInviteTableView.reloadData()
    }

    @objc func cancel(send: Any) {
        guard let button = send as? UIButton else { return }
        guard let contentView = button.superview else { return }
        guard let cell = contentView.superview as? UITableViewCell else { return }
        guard let indexPath = checkInviteTableView.indexPath(for: cell) else { return }
        let autoID = recipient[indexPath.row].autoID
        ref = Database.database().reference()
        ref?.child("wait").child("\(autoID)").removeValue()
        recipient.remove(at: indexPath.row)
        self.checkInviteTableView.reloadData()
    }

    func setGoBackButton() {
        let backButton = UIBarButtonItem()
        backButton.image = #imageLiteral(resourceName: "GO_BACK")
        backButton.target = self
        backButton.action = #selector(goBack)
        self.navigationItem.leftBarButtonItem = backButton
    }

}
