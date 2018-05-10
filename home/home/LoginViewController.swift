//
//  LoginViewController.swift
//  home
//
//  Created by Evans Wu on 2018/5/9.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation
import UIKit
import QuickbloxWebRTC
import Quickblox
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
var currentUser: QBUUser?
var users: [String : String]?

override func viewDidLoad() {
    super.viewDidLoad()
    
    // fetching users from Users.plist
    if let path = Bundle.main.path(forResource: "Users", ofType: "plist"){
        users = NSDictionary(contentsOfFile: path) as? [String : String]
    }
    
    precondition(users!.count > 1, "The Users.plist file should contain at least 2 and max 4 users with format [login:password]. Please go to https://admin.quickblox.com and create users in 'Users' module.")
    
    precondition(users!.count <= 4, "Maximum of 4 sample users are recommended. Please remove other ones.")
}

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.loginButton.isHidden = false
}

    //MARK: - Actions

    @IBAction func didLogin(_ sender: UIButton) {
        presentUsersList()
    }
    func presentUsersList() {
        
        let alert = UIAlertController(title: "Login as:", message: nil, preferredStyle: .actionSheet)
        
        for (_, user) in users!.enumerated() {
            let user = UIAlertAction(title: user.key, style: .default) { action in
                self.login(userLogin: user.key, password: user.value)
            }
            alert.addAction(user)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.loginButton.isHidden = false
        }
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
        self.loginButton.isHidden = true
    }
    
    func login(userLogin: String, password: String) {
        SVProgressHUD.show(withStatus: "Logining to rest")
        QBRequest.logIn(withUserLogin: userLogin, password: password, successBlock:{ r, user in
            self.currentUser = user
            SVProgressHUD.show(withStatus: "Connecting to chat")
            QBChat.instance.connect(with: user) { err in
                let logins = self.users?.keys.filter {$0 != user.login}
                SVProgressHUD.show(withStatus: "Geting users Info")
                QBRequest.users(withLogins: logins!, page:nil, successBlock: { r, p, users in
                    self.performSegue(withIdentifier: "GOHOME", sender:users)
                    SVProgressHUD.dismiss()
                })
            }
        })
    }
    //這邊再傳資料
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let homeVC  = segue.destination as! HomeViewController
        homeVC.opponets = sender as? [QBUUser]
        homeVC.currentUser = self.currentUser
    }
    
}
