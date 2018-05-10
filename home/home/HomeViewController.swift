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
    
    
    open var opponets: [QBUUser]?
    open var currentUser: QBUUser?
    var session: QBRTCSession?
    
    //audio
    func configureAudio() {
        
        // let conf = QBRTCMediaStreamConfiguration.defaultConfiguration()
        // conf.audioCodec = QBRTCAudioCodec.CodeciLBC
        // QBRTCConfig.setMediaStreamConfiguration(conf)
        
        QBRTCConfig.mediaStreamConfiguration().audioCodec = .codecOpus  //
        //initialize audio session with a specific configuration
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
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.setHidesBackButton(true, animated:true)
//        self.navigationItem.backBarButtonItem?.backButtonBackgroundImage(for: <#T##UIControlState#>, barMetrics: <#T##UIBarMetrics#>)
        
        // Initialize QuickbloxWebRTC and configure signaling <- 初始化QuickbloxWebRTC跟配置信號？
        QBRTCClient.initializeRTC()
        // self class must conform to QBRTCClientDelegate protocol <- 不懂
        QBRTCClient.instance().add(self)
        configureAudio()
        
    }

    //打電話
    @IBAction func didPressCall(_ sender: UIButton) {
        guard
            let ids: [NSNumber] = self.opponets?.map({ (element: QBCEntity) -> NSNumber in
                return NSNumber(value: element.id)}) else { return }//handle error
        
        self.session = QBRTCClient.instance().createNewSession(withOpponents: ids,
            with: .audio)
        self.session?.startCall(["info" : "user info"])
        
    }
    //掛電話
    @IBAction func didPressEnd(_ sender: UIButton) {
        if self.session != nil {
            self.session?.hangUp(nil)
        }
    }
    @IBAction func didLogout(_ sender: UIButton) {
        logout()
    }
    func logout() {
        
        SVProgressHUD.show(withStatus: "Logout")
        QBChat.instance.disconnect { _ in
            QBRequest.logOut(successBlock: { _ in
                SVProgressHUD.dismiss()
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        
        if session.id == self.session?.id {
            if userID == session.initiatorID {
                self.session?.hangUp(nil)
            }
        }
    }
    
    //接電話
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        
        if self.session == nil {
            self.session = session
            handleIncomingCall()
        }
    }
    
    func handleIncomingCall() {
        let alert = UIAlertController(title: "Incoming video call", message: "Accept ?", preferredStyle: .actionSheet)
        let accept = UIAlertAction(title: "Accept", style: .default) { action in
            
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
//
//        if (session as! QBRTCSession).id == self.session?.id {
//            if session.conferenceType == QBRTCConferenceType.video {
//
//            }
//        }
//    }
}

