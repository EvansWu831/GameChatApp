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

class HomeViewController: UIViewController, QBRTCClientDelegate, InviteFriendDelegate {

    var currentUser: QBUUser?
    var session: QBRTCSession?
    var inviteFriends: [NSNumber]?
    var initiatorID: NSNumber?

    override func viewDidLoad() {
        super.viewDidLoad()
        QBRTCClient.initializeRTC()
        QBRTCClient.instance().add(self)
        configureAudio()

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
        //打電話
        let callButton = UIBarButtonItem()
        callButton.image = #imageLiteral(resourceName: "CALL")
        callButton.target = self
        callButton.action = #selector(didCall)
        //朋友
        let friendButton = UIBarButtonItem()
        friendButton.image = #imageLiteral(resourceName: "FRIEND")
        friendButton.target = self
        friendButton.action = #selector(friendButtonAction)
        self.navigationItem.rightBarButtonItems = [callButton, friendButton]
        //背景圖片
        setBackgroundImage()
    }
    //打電話後畫面
    func setSelfHome() {
        self.navigationItem.title = "房間"
        //出門
        let exitButton = UIBarButtonItem()
        exitButton.image = #imageLiteral(resourceName: "GO_OUT")
        exitButton.target = self
        exitButton.action = #selector(didEnd)
        self.navigationItem.leftBarButtonItem = exitButton
        //邀請
        let callButton = UIBarButtonItem()
        callButton.image = #imageLiteral(resourceName: "CALL")
        callButton.target = self
        callButton.action = #selector(didCall)
        //朋友
        let friendButton = UIBarButtonItem()
        friendButton.image = #imageLiteral(resourceName: "FRIEND")
        friendButton.target = self
        friendButton.action = #selector(friendButtonAction)
        self.navigationItem.rightBarButtonItems = [callButton, friendButton]
    }
    //受邀請時頁面
    func setFriendHome() {
        self.navigationItem.title = "房間"
        //出門
        let exitButton = UIBarButtonItem()
        exitButton.image = #imageLiteral(resourceName: "GO_OUT")
        exitButton.target = self
        exitButton.action = #selector(didEnd)
        self.navigationItem.leftBarButtonItem = exitButton
        self.navigationItem.rightBarButtonItems = []
    }

    //friend action
    @objc func friendButtonAction() {
        self.performSegue(withIdentifier: "GO_FRIEND", sender: nil)
    }

    //登出
    @objc func logout() {
        SVProgressHUD.show(withStatus: "登出")
        QBChat.instance.disconnect { _ in
            QBRequest.logOut(successBlock: { _ in
                SVProgressHUD.dismiss()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                guard let navigationController = storyboard.instantiateViewController(withIdentifier: "FIRST")
                    as? UINavigationController
                    else { return } //handle error

                self.present(navigationController, animated: true, completion: nil)
            })
        }
    }
    //掛電話
    @objc func didEnd() {
        if self.session != nil {
            self.session?.hangUp(nil)
            print("掛電話")
            inviteFriends = nil
            setHouse()
        } else {
            print("沒電話可以掛")
            inviteFriends = nil
            setHouse()
        }
    }
    //打電話
    @objc func didCall() {
        self.performSegue(withIdentifier: "GO_INVITE", sender: nil)
    }

    func callFriends() {

        if let ids = inviteFriends {
            guard let user = currentUser else { return } //handle error
            QBChat.instance.connect(with: user) { _ in
                self.session = QBRTCClient.instance().createNewSession(withOpponents: ids, with: .audio)
                self.session?.startCall(nil)
                self.setSelfHome()
            }
        } else {
            let alert = UIAlertController(title: nil, message: "還沒邀請朋友", preferredStyle: .alert)
            let action = UIAlertAction(title: "確認", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }

    }
    //電話掛斷時觸發
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String: String]? = nil) {
        if session.id == self.session?.id {
            if userID == session.initiatorID {
                self.session?.hangUp(nil)
            } else {  } //handle error
        } else {  } //handle error
    }
    func sessionDidClose(_ session: QBRTCSession) {
        if session.id == self.session?.id {
            self.session = nil
            setHouse()
        } else {  } //handle error
    }

    //接電話
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String: String]? = nil) {
        if self.session == nil {
            self.session = session
            handleIncomingCall()
            initiatorID = session.initiatorID
        } else {
            if initiatorID == session.initiatorID {
                self.session = session
                self.session?.acceptCall(nil)
            } else {
                let alert = UIAlertController(title: nil, message: "有人插播", preferredStyle: .alert)
                let action = UIAlertAction(title: "確認", style: .default)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
    }

    func handleIncomingCall() {
        let alert = UIAlertController(title: "有人來電", message: nil, preferredStyle: .actionSheet)
        let accept = UIAlertAction(title: "接聽", style: .default) { _ in
            self.setFriendHome()
            self.session?.acceptCall(nil)
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
        } else { }//error handel
    }
}
