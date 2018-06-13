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
        if let friends = inviteFriends {
            return friends.count
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
            if let friends = inviteFriends {
                let friend = friends[indexPath.row]
                let storage = Storage.storage().reference(withPath: "\(friend)/userImage.jpg")
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
    func setSelfHome() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        //朋友
        let friendButton = UIBarButtonItem()
        friendButton.image = #imageLiteral(resourceName: "FRIEND")
        friendButton.target = self
        friendButton.action = #selector(friendButtonAction)
        self.navigationItem.rightBarButtonItem = friendButton
    }
    //受邀請時頁面
    func setFriendHome() {
        //出門
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
    }

    func callFriends() {

        if let ids = inviteFriends {
            guard let user = currentUser else { return } //handle error
            QBChat.instance.connect(with: user) { _ in
                self.session = QBRTCClient.instance().createNewSession(withOpponents: ids, with: .audio)
                self.session?.startCall(nil)
                self.setSelfHome()

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

    //似乎只有在房間要被掛掉的時候才會進來
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String: String]? = nil) {
        print("這裡電話掛斷時觸發", userID)
        if session.id == self.session?.id {
            print("這裡在確認要關的房間", session.id)
            if userID != session.initiatorID {
                print("這裡房客離開房間")
                //房客離開房間
                guard let currentUserId = self.currentUser?.id else { return }
                guard let initiatorUserId = initiatorID else { return }
                self.reference = Database.database().reference()
                self.reference?.child("room").child("\(initiatorUserId)").child("\(currentUserId)").removeValue()
            } else {
                print("這裡房主關房間")
                self.session?.hangUp(nil)
                //房主關房間
                guard let currentUserId = self.currentUser?.id else { return }
                self.reference = Database.database().reference()
                self.reference?.child("room").child("\(currentUserId)").removeValue()
            }
        } else {
            print("這裡發生什麼事了")
        } //handle error
    }
    //這裡是自己掛電話時才會進來
    func sessionDidClose(_ session: QBRTCSession) {
        print("這裡掛電話")
        if session.id == self.session?.id {
            self.session = nil
            setHouse()
            phoneCallButton.isHidden = false
            hangUpButton.isHidden = true
            userImagesTableView.isHidden = true
            userImagesTableView.reloadData()
            print("這裡執行掛電話後的動作")
        } else { print("這裡沒掛成功") } //handle error
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
                    self.setFriendHome()
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
        guard let initiatorUser = initiatorID else { return }
        let alert = UIAlertController(title: "\(initiatorUser)有人來電", message: nil, preferredStyle: .actionSheet)
        let accept = UIAlertAction(title: "接聽", style: .default) { _ in
            self.setFriendHome()
            self.session?.acceptCall(nil)
            //進入房間(用firebase)
//            guard let currentUserId = self.currentUser?.id else { return }
//            self.reference = Database.database().reference()
//            self.reference?.child("room").child("\(initiatorUser)").setValue(["\(currentUserId)": currentUserId])
        }
        let reject = UIAlertAction(title: " 掛斷", style: .default) { _ in
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
            userImagesTableView.reloadData()
        } else { }//error handel
    }
}
