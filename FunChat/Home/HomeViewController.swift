//
//  ViewController.swift
//  home
//
//  Created by Evans Wu on 2018/5/8.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD
import Firebase
import FirebaseStorage
import Crashlytics

class HomeViewController: UIViewController, QBRTCClientDelegate, InviteFriendDelegate,
UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var phoneCallButton: UIButton!
    @IBOutlet weak var hangUpButton: UIButton!
    @IBOutlet weak var userImagesTableView: UITableView!
    var reference: DatabaseReference?
    var currentUser: QBUUser?
    var session: QBRTCSession?
    var inviteFriends: [NSNumber]?
    var initiatorID: NSNumber?
    var room: [Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
        QBRTCClient.initializeRTC()
        QBRTCClient.instance().add(self)
        configureAudio()

        setHangUpBtton()
        setPhoneCallButton()
        setHouse()
        setBackgroundImage()
    }

    //成為代理人
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let inviteVC = segue.destination as? InviteFriendViewController {
            inviteVC.delegate = self
            inviteVC.currentUser = self.currentUser
        } else { print("沒進去inviteVC") } //handle error

        if let friendVC = segue.destination as? FriendViewController {
            friendVC.currentUser = self.currentUser
        } else { print("沒進去friendVC") } //handle error

    }

    func manager(_ manager: InviteFriendViewController, didFetch ids: [NSNumber]) {
        inviteFriends = ids
        callFriends()
    }
    //UserImages
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let room = room {
            return room.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = userImagesTableView.dequeueReusableCell(withIdentifier: "USERIMAGES_CELL",
                                                              for: indexPath) as? UserImagesTableViewCell {
            cell.userImageView.layer.masksToBounds = true
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            //===============還在測試====
            if let userIDs = room {
                let userId = userIDs[indexPath.row]
                let storage = Storage.storage().reference(withPath: "\(userId)/userImage.jpg")
                storage.getData(maxSize: 1*1000*1000) { (data, _) in
                    if let image = data {
                        cell.userImageView.image = UIImage(data: image)
                    } else {
                        cell.userImageView.image = #imageLiteral(resourceName: "USERIMAGE")
                    }
                }
            } else {
                cell.userImageView.image = #imageLiteral(resourceName: "USERIMAGE")
            }
            //==========================
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func getRoomIDs() {
        reference = Database.database().reference()
        let path = reference?.child("room").child("\(initiatorID!)")
        path?.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let values = snapshot.value as? [String: Any] else { print("失敗") ; return }
            var ids: [Any] = []
            for value in values.values {
                ids.append(value)
            }
            self.room = ids
            self.userImagesTableView.reloadData()
        })
    }

    //audio
    func configureAudio() {
        QBRTCConfig.mediaStreamConfiguration().audioCodec = .codecOpus
        QBRTCAudioSession.instance().initialize { (configuration: QBRTCAudioSessionConfiguration) in
            var options = configuration.categoryOptions
            if #available(iOS 10.0, *) {
                options = options.union(AVAudioSessionCategoryOptions.allowBluetoothA2DP)
                options = options.union(AVAudioSessionCategoryOptions.allowAirPlay)
            } else {
                options = options.union(AVAudioSessionCategoryOptions.allowBluetooth)
            }
            configuration.categoryOptions = options
            configuration.mode = AVAudioSessionModeVideoChat
        }
        QBRTCAudioSession.instance().currentAudioDevice = .speaker
    }

    //House頁面
    func setBackgroundImage() {
        UIGraphicsBeginImageContext(view.frame.size)
        var image = UIImage(named: "HOME")
        image?.draw(in: view.bounds)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        view.backgroundColor = UIColor(patternImage: image!)
    }

    func setChatBackgroundImage() {
        UIGraphicsBeginImageContext(view.frame.size)
        var image = UIImage(named: "HOMEPARTY")
        image?.draw(in: view.bounds)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        view.backgroundColor = UIColor(patternImage: image!)
    }

    //打電話前畫面
    func setHouse() {
        self.navigationItem.title = "房間"
        //登出
        let exitButton = UIBarButtonItem()
        exitButton.image = #imageLiteral(resourceName: "EXIT")
        exitButton.target = self
        exitButton.action = #selector(logout)
        self.navigationItem.leftBarButtonItem = exitButton
        //更改為文字
        let friendButton = UIBarButtonItem()
        friendButton.image = #imageLiteral(resourceName: "FRIEND")
        friendButton.target = self
        friendButton.action = #selector(friendButtonAction)
        self.navigationItem.rightBarButtonItem = friendButton
        //背景圖片
        setBackgroundImage()
        userImagesTableView.isHidden = true
    }

    //打電話後畫面
    func setCallingView() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        
    }

    //friend action
    @objc func friendButtonAction() {
        self.performSegue(withIdentifier: "GO_FRIEND", sender: nil)
    }

    //登出
    @objc func logout() {
        let alert = UIAlertController(title: "登出", message: "要登出嗎？", preferredStyle: .alert)
        let agree = UIAlertAction(title: "確定", style: .default) { (_) in
            SVProgressHUD.show(withStatus: "登出")
            QBChat.instance.disconnect { _ in
                QBRequest.logOut(successBlock: { _ in
                    UserDefaults.standard.removeObject(forKey: "login")
                    UserDefaults.standard.removeObject(forKey: "password")
                    SVProgressHUD.dismiss()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let navigationController = storyboard.instantiateViewController(withIdentifier: "FIRST")
                        as? UINavigationController
                        else { return } //handle error
                    self.present(navigationController, animated: true, completion: nil)
                })
            }
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(agree)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    //設置按鈕
    func setHangUpBtton() {
        hangUpButton.isHidden = true
        hangUpButton.addTarget(self, action: #selector(didEnd), for: .touchUpInside)
        hangUpButton.layer.shadowColor = UIColor.black.cgColor
        hangUpButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        hangUpButton.layer.shadowOpacity = 1.0
        hangUpButton.layer.shadowRadius = 2.0
    }

    func setPhoneCallButton() {
        phoneCallButton.layer.shadowColor = UIColor.black.cgColor
        phoneCallButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        phoneCallButton.layer.shadowOpacity = 1.0
        phoneCallButton.layer.shadowRadius = 2.0
    }

    @objc func didEnd() {
        let alert = UIAlertController(title: "掛掉電話", message: "要掛掉電話嗎？", preferredStyle: .alert)
        let agree = UIAlertAction(title: "確定", style: .default) { (_) in
            if self.session != nil {
                self.session?.hangUp(nil)
                self.inviteFriends = nil
                self.setHouse()
            } else {
                self.inviteFriends = nil
                self.setHouse()
            }
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(agree)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    //打電話
    @IBAction func didPhoneCall(_ sender: UIButton) {
         self.performSegue(withIdentifier: "GO_INVITE", sender: nil)
        if let currentUserID = currentUser?.id {
            initiatorID = currentUserID as NSNumber
        }
    }

    func callFriends() {

        //分析使用者
        Analytics.logEvent("phone_call", parameters: nil)

        if let ids = inviteFriends {
            guard let user = currentUser else { return } //handle error
            QBChat.instance.connect(with: user) { _ in
                self.session = QBRTCClient.instance().createNewSession(withOpponents: ids, with: .audio)
                self.session?.startCall(nil)
                self.setCallingView()
                //房主建立房間
                guard let currentUserId = self.currentUser?.id else { return }
                self.reference = Database.database().reference()
                self.reference?.child("room").child("\(currentUserId)").setValue(["master": currentUserId])
            }
        } else {
            let alert = UIAlertController(title: nil, message: "還沒邀請朋友", preferredStyle: .alert)
            let action = UIAlertAction(title: "確認", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }

    }

    //有人掛掉電話時觸發
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String: String]? = nil) {

        if session.id == self.session?.id {
            if userID != session.initiatorID {
                //告知有房客離開
                getRoomIDs()
            } else {
                //房主離開
                self.session?.hangUp(nil)
            }
        } else { } //handle error
    }

    //這裡是自己掛電話時才會進來
    func sessionDidClose(_ session: QBRTCSession) {
        //分析使用者
        Analytics.logEvent("phone_hangup", parameters: nil)

        guard let currentUserId = self.currentUser?.id else { return }
        guard let initiatorUser = initiatorID as? UInt else { return }

        if currentUserId != initiatorUser {
            self.reference = Database.database().reference()
            self.reference?.child("room").child("\(initiatorUser)").child("\(currentUserId)").removeValue()
            print("這裡房客離開")
        } else {
            self.reference = Database.database().reference()
            self.reference?.child("room").child("\(currentUserId)").removeValue()
            print("這裡房主關房間")
        }

        self.session = nil
        setHouse()
        phoneCallButton.isHidden = false
        hangUpButton.isHidden = true
        userImagesTableView.isHidden = true
        userImagesTableView.reloadData()

    }

    //接電話
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String: String]? = nil) {
        if self.session == nil {
            self.session = session
            initiatorID = session.initiatorID
            handleIncomingCall()
        } else {
            if initiatorID == session.initiatorID {
                self.session = session
                self.session?.acceptCall(nil)
            } else {
                let alert = UIAlertController(title: nil, message: "有人插播", preferredStyle: .alert)
                let accept = UIAlertAction(title: "接聽", style: .default) { _ in
                    self.setCallingView()
                    self.session?.acceptCall(nil)
                }
                let reject = UIAlertAction(title: " 掛斷", style: .default) { _ in
                    self.session?.rejectCall(nil)
                }
                alert.addAction(accept)
                alert.addAction(reject)
                present(alert, animated: true, completion: nil)
            }
        }
    }

    func handleIncomingCall() {
        let alert = UIAlertController(title: "有人來電", message: nil, preferredStyle: .actionSheet)
        let accept = UIAlertAction(title: "接聽", style: .default) { _ in
            //分析使用者
            Analytics.logEvent("phone_accept", parameters: nil)

            self.session?.acceptCall(nil)
        }
        let reject = UIAlertAction(title: " 掛斷", style: .default) { _ in
            //分析使用者
            Analytics.logEvent("phone_reject", parameters: nil)

            self.session?.rejectCall(nil)
        }
        alert.addAction(accept)
        alert.addAction(reject)
        self.present(alert, animated: true)
    }

//    接通時動作
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
        if (session as? QBRTCSession)?.id == self.session?.id {
            setChatBackgroundImage()
            hangUpButton.isHidden = false
            phoneCallButton.isHidden = true
            userImagesTableView.isHidden = false
            guard let currentUserId = self.currentUser?.id else { return }
            guard let initiatorUser = initiatorID as? UInt else { return }
            if currentUserId != initiatorUser {
                self.setCallingView()
                self.reference = Database.database().reference()
                self.reference?.child("room").child("\(initiatorUser)").child("\(currentUserId)").setValue(currentUserId)
            } else {
                self.setCallingView()
            }
            getRoomIDs()
        } else { }//error handel
    }
}
