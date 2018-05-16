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

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func didLogin(_ sender: UIButton) {

        if let userId = idTextField.text {
            if let password = passwordTextField.text {
                if !userId.isEmpty {
                    if password != "" {
                        login(userLogin: userId, password: password)
                    } else {
                        let alert = UIAlertController(title: "錯誤", message: "密碼空白", preferredStyle: .alert)
                        let action = UIAlertAction(title: "確認", style: .default)
                        alert.addAction(action)
                        present(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "錯誤", message: "帳號空白", preferredStyle: .alert)
                    let action = UIAlertAction(title: "確認", style: .default)
                    alert.addAction(action)
                    present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "錯誤", message: "請重新輸入帳號密碼", preferredStyle: .alert)
                let action = UIAlertAction(title: "確認", style: .default) { (_) in
                    self.textClearance()
                }
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "錯誤", message: "請重新輸入帳號密碼", preferredStyle: .alert)
            let action = UIAlertAction(title: "確認", style: .default) { (_) in
                self.textClearance()
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }

    func textClearance() {
        idTextField.text = ""
        passwordTextField.text = ""
    }

    func login(userLogin: String, password: String) {
        SVProgressHUD.show(withStatus: "Logining to rest")
        QBRequest.logIn(withUserLogin: userLogin, password: password, successBlock: { _, user in
            SVProgressHUD.show(withStatus: "Connecting to chat")
            QBChat.instance.connect(with: user) { _ in
                self.performSegue(withIdentifier: "GOHOME", sender: user)
                SVProgressHUD.dismiss()
            }

            },
            errorBlock: { _ in
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "錯誤", message: "帳號密碼錯誤", preferredStyle: .alert)
                let action = UIAlertAction(title: "確認", style: .default) { (_) in
                    self.textClearance()
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
        }
        )
    }
    //傳資料
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let homeVC  = segue.destination as? HomeViewController else { return } //handle error
        homeVC.currentUser = sender as? QBUUser
    }
}
