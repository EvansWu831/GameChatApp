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

class HomeViewController: UIViewController,QBRTCClientDelegate {
    
    open var currentUser: QBUUser?
    var session: QBRTCSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QBRTCClient.initializeRTC()
        QBRTCClient.instance().add(self)
        configureAudio()
        setHouse()
    }
    
    @IBOutlet weak var peoplesView: UIView!
    @IBOutlet weak var usersImage: UIImageView!
    @IBOutlet weak var goHomeButton: UIButton!
    @IBAction func goHome(_ sender: UIButton) {
        goHomeButton.isHidden = true
        peoplesView.isHidden = false
        setSelfHome()
    }
    
    @IBOutlet weak var inviteFriendButton: UIButton!
    @IBAction func inviteFriends(_ sender: UIButton) {
//        let alert = UIAlertController(title: "Friend", message: nil, preferredStyle: .actionSheet)
//        alert.addChildViewController(<#T##childController: UIViewController##UIViewController#>)
//        alert.show(<#T##vc: UIViewController##UIViewController#>, sender: <#T##Any?#>)
        print("invite")
    }
    
    
    //audio
    func configureAudio() {
        QBRTCConfig.mediaStreamConfiguration().audioCodec = .codecOpus
        QBRTCAudioSession.instance().initialize { (configuration: QBRTCAudioSessionConfiguration) -> () in

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
    func setHouse() {
        self.navigationItem.title = "House"
        //登出
        let exitButton = UIBarButtonItem()
        exitButton.image = #imageLiteral(resourceName: "EXIT")
        exitButton.target = self
        exitButton.action = #selector(logout)
        self.navigationItem.leftBarButtonItem = exitButton
        //右邊按鈕
        let friendButton = UIBarButtonItem()
        friendButton.image = #imageLiteral(resourceName: "FRIEND")
        self.navigationItem.rightBarButtonItems = [friendButton]
        peoplesView.isHidden = true
    }
    //Home頁面
    func setSelfHome() {
        self.navigationItem.title = "Home"
        //出門
        let exitButton = UIBarButtonItem()
        exitButton.image = #imageLiteral(resourceName: "GOOUT")
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
        self.navigationItem.rightBarButtonItems = [callButton, friendButton]
        //頭像
        peoplesView.isHidden = false
        inviteFriendButton.isHidden = false
        setUsersImage()
    }
    //FriendHome頁面
    func setFriendHome() {
        self.navigationItem.title = "Home"
        //出門
        let exitButton = UIBarButtonItem()
        exitButton.image = #imageLiteral(resourceName: "GOOUT")
        exitButton.target = self
        exitButton.action = #selector(didEnd)
        self.navigationItem.leftBarButtonItem = exitButton
        self.navigationItem.rightBarButtonItems = []
        //頭像
        peoplesView.isHidden = false
        inviteFriendButton.isHidden = true
        setUsersImage()
        
    }
    //使用者小頭像
    func setUsersImage() {
        usersImage.image = #imageLiteral(resourceName: "USERIMAGE")
        usersImage.layer.masksToBounds = true
        usersImage.layer.cornerRadius = usersImage.frame.width/2
    }
    
    //登出
    @objc func logout() {
        SVProgressHUD.show(withStatus: "Logout")
        QBChat.instance.disconnect { _ in
            QBRequest.logOut(successBlock: { _ in
                SVProgressHUD.dismiss()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let navigationController = storyboard.instantiateViewController(withIdentifier: "FIRST") as! UINavigationController
                self.present(navigationController, animated: true, completion: nil)
            })
        }
    }
    //掛電話
    @objc func didEnd() {
        
        if self.session != nil {
            self.session?.hangUp(nil)
            print("掛電話")
        }
        else {
            setHouse()
            goHomeButton.isHidden = false
            print("沒電話可以掛")
        }
    }
    //打電話
    @objc func didCall() {
            QBChat.instance.connect(with: currentUser!) { err in
                self.session = QBRTCClient.instance().createNewSession(withOpponents: [49401608, 49401615, 49401640], with: .audio)
                self.session?.startCall(nil)
            }
    }
    //電話掛斷時觸發
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        
        if session.id == self.session?.id {
            if userID == session.initiatorID {
                self.session?.hangUp(nil)
            } else { print("22222") }
        } else { print("11111") }
    }
    func sessionDidClose(_ session: QBRTCSession) {
        if session.id == self.session?.id {
            self.session = nil
            setHouse()
            goHomeButton.isHidden = false
        } else {print("33333") }
    }
    
    //接電話
    var initiatorID: NSNumber?
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if self.session == nil {
            self.session = session
            handleIncomingCall()
            initiatorID = session.initiatorID
        }
        else {
            if initiatorID == session.initiatorID {
                self.session = session
                self.session?.acceptCall(nil)
            }
            else {
                //別人插播
                print("有人插播")
            }
        }
    }
    
    func handleIncomingCall() {
        let alert = UIAlertController(title: "Incoming call", message: "Accept ?", preferredStyle: .actionSheet)
        let accept = UIAlertAction(title: "Accept", style: .default) { action in
            self.goHomeButton.isHidden = true
            self.setFriendHome()
            self.session?.acceptCall(nil)
        }
        let reject = UIAlertAction(title: "Reject", style: .default) { action in
            self.session?.rejectCall(nil)
        }
        alert.addAction(accept)
        alert.addAction(reject)
        self.present(alert, animated: true)
        
        
    }
    //當接通其他用戶時動作
//    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
//        if (session as! QBRTCSession).id == self.session?.id {
//
//        }
//    }
}

