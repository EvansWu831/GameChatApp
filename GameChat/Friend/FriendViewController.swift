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
import Firebase
import FirebaseStorage

class FriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
GetUserInfoDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!
    var myself: User?
    var myFriend: [User] = []
    var currentUser: QBUUser?
    let getUserInfoManager = GetUserInfoManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setAddFriendButton()
        getInfo()
        setUserImage()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addFriendVC = segue.destination as? AddFriendViewController {
            addFriendVC.currentUser = self.currentUser
        } else { } //handle error

        if let checkInviteVC = segue.destination as? CheckInviteViewController {
            checkInviteVC.friendGetUserInfoManager = self.getUserInfoManager
            checkInviteVC.currentUser = self.currentUser
        } else { } //handle error
    }

    func manager(_ manager: GetUserInfoManager, sender users: [User]) {
    }

    func manager(_ manager: GetUserInfoManager, recipient users: [User]) {
    }

    func manager(_ manager: GetUserInfoManager, didFetch users: [User]) {
        myFriend = users
        friendsTableView.reloadData()
    }

    func manager(_ manager: GetUserInfoManager, didFetch user: User) {

        myself = user
        if user.nickname.isEmpty {
            userNameLabel.text = user.login
        } else {
            userNameLabel.text = user.nickname
        }
        downloadImage()
    }

    func manager(_ manager: GetUserInfoManager, error: Error) {
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFriend.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "朋友"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var userCell = UITableViewCell()
        if let cell = friendsTableView.dequeueReusableCell(withIdentifier: "FRIEND_CELL", for: indexPath)
            as? FriendTableViewCell {
            let friend = myFriend[indexPath.row]
            cell.friendImageView.layer.masksToBounds = true
            cell.friendImageView.layer.cornerRadius = cell.friendImageView.frame.width/2
            cell.friendNameLabel.numberOfLines = 0
            if friend.nickname.isEmpty {
                cell.friendNameLabel.text = "\(friend.login)"
            } else {
                cell.friendNameLabel.text = "\(friend.nickname)"
            }
            let storage = Storage.storage().reference(withPath: "\(friend.userID)/userImage.jpg")
            storage.getData(maxSize: 1*1000*1000) { (data, _) in
                if let image = data {
                    cell.friendImageView.image = UIImage(data: image)
                } else {
                    cell.friendImageView.image = #imageLiteral(resourceName: "USERIMAGE")
                }
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
    //更改刪除Button名稱
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "封鎖"
    }
    //實作封鎖功能
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard let currentUserID = currentUser?.id else { return } //handle error
        if editingStyle == UITableViewCellEditingStyle.delete {
            let reference = Database.database().reference()
            let friend = myFriend[indexPath.row]
            let path = reference.child("relationship").queryOrdered(byChild: "friend")
            path.queryEqual(toValue: currentUserID).observeSingleEvent(of: .value) { (relationshipData) in
                guard let relationship = relationshipData.value as? [String: Any] else { return } //error handle
                for relationshipAutoKey in relationship.keys {
                    if let blackFriend = relationship["\(relationshipAutoKey)"] as? [String: Any] {
                        if let blackID = blackFriend["self"] as? NSNumber {
                            if blackID == friend.userID {
                                reference.child("relationship").child("\(friend.autoID)").removeValue()
                                reference.child("relationship").child("\(relationshipAutoKey)").removeValue()
                                reference.child("blacklist").childByAutoId().setValue(["sender": currentUserID, "black": friend.userID])
                            } else { } //handle error
                        } else { } //handle error
                    } else { } //handel error
                }
                self.myFriend.remove(at: indexPath.row)
                self.friendsTableView.reloadData()
            }
        } else {} //handle error
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
        addFriendButton.image = #imageLiteral(resourceName: "ADD_FRIEND")
        addFriendButton.target = self
        addFriendButton.action = #selector(goAddFriend)

        let checkInviteButton = UIBarButtonItem()
        checkInviteButton.image = #imageLiteral(resourceName: "CHECK_INVITE")
        checkInviteButton.target = self
        checkInviteButton.action = #selector(goCheckInvite)
        self.navigationItem.rightBarButtonItems = [addFriendButton, checkInviteButton]

        let backButton = UIBarButtonItem()
        backButton.image = #imageLiteral(resourceName: "GO_BACK")
        backButton.target = self
        backButton.action = #selector(goBack)
        self.navigationItem.leftBarButtonItem = backButton
    }

    //set image action
    func setUserImage() {
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(imageTapped(tapGestureRecognizer:)))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let picker: UIImagePickerController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            uploadImage(image: image)
        } else {} //handle error
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    //上傳圖片
    func uploadImage(image: UIImage) {
        guard let userID = currentUser?.id else { return } //handle error
        let userImage = UIImageJPEGRepresentation(image, 0.0)
        let storage = Storage.storage().reference(withPath: "\(userID)/userImage.jpg")
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        storage.putData(userImage!, metadata: uploadMetadata) { (_, error) in
            if error == nil {
                self.downloadImage()
            } else {
                print("error") //handle error
            }
        }
    }
    //下載圖片
    func downloadImage() {
        guard let userID = currentUser?.id else { return } //handle error
        let storage = Storage.storage().reference(withPath: "\(userID)/userImage.jpg")
        storage.getData(maxSize: 1*1000*1000) { (data, _) in
            if let image = data {
                self.userImageView.image = UIImage(data: image)
            } else {
                self.userImageView.image = #imageLiteral(resourceName: "USERIMAGE")
            }
        }
    }

    @IBAction func tappedUserNameButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "更改暱稱", message: nil, preferredStyle: .alert)
        var nameTextField: UITextField?
        alert.addTextField { (textField) in
            textField.text = self.userNameLabel.text
            nameTextField = textField
        }
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (_) in
            guard let autoID = self.myself?.autoID else { return } //handleerror
            let ref = Database.database().reference()
            let path = ref.child("user").child("\(autoID)").child("nickname")
            path.setValue(nameTextField?.text, withCompletionBlock: { (error, _) in
                if error == nil {
                    self.updatedUserName()
                } else {
                    print("失敗") //handle error
                }
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func updatedUserName() {
        guard let autoID = self.myself?.autoID else { return } //handleerror
        let ref = Database.database().reference()
        let path = ref.child("user").child("\(autoID)").child("nickname")
        path.observe(.value) { (snapshot) in
            if let nickname = snapshot.value as? String {
                self.userNameLabel.text = nickname
            } else {} //handle error
        }
    }
}
