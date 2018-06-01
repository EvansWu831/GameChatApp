//
//  SignUpViewController.swift
//  home
//
//  Created by Evans Wu on 2018/5/17.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation
import UIKit
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setGoBackButton()
    }

    func setGoBackButton() {
        let backButton = UIBarButtonItem()
        backButton.image = #imageLiteral(resourceName: "GO_BACK")
        backButton.target = self
        backButton.action = #selector(goBack)
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = "註冊"
    }

    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func didSingUp(_ sender: UIButton) {

        guard let nickname = nicknameTextField.text else {
            let alert = UIAlertController(title: "錯誤", message: "請重新輸入暱稱", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }

        guard let email = emailTextField.text else {
            let alert = UIAlertController(title: "錯誤", message: "請重新輸入信箱", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }

        guard let userName = userNameTextField.text else {
            let alert = UIAlertController(title: "錯誤", message: "請重新輸入帳號", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }

        guard let password = passwordTextField.text else {
            let alert = UIAlertController(title: "錯誤", message: "請重新輸入密碼", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }

        guard let confirmPassword = confirmPasswordTextField.text else {
            let alert = UIAlertController(title: "錯誤", message: "請再次確認密碼", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }

        guard !email.isEmpty else {
            let alert = UIAlertController(title: "錯誤", message: "信箱空白", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }

        guard !userName.isEmpty else {
            let alert = UIAlertController(title: "錯誤", message: "帳號空白", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }

        guard !password.isEmpty else {
            let alert = UIAlertController(title: "錯誤", message: "密碼空白", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }

        guard password.count >= 8 else {
            let alert = UIAlertController(title: "錯誤", message: "密碼長度不能小於8個字", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }

        if !confirmPassword.isEmpty && password == confirmPassword {
            signUp(userName: userName, password: password, email: email, nickname: nickname)
        } else {
            let alert = UIAlertController(title: "錯誤", message: "與密碼不一致", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }

    func signUp(userName: String, password: String, email: String, nickname: String) {
        let newUser = QBUUser()
        newUser.login = userName
        newUser.password = password
        newUser.email = email
        QBRequest.signUp(newUser, successBlock: { (response, user) in
            self.addUser(user: ["id": user.id, "email": "\(user.email!)", "login": "\(user.login!)", "nickname": "\(nickname)"])
            self.login(userLogin: userName, password: password)
        })
        { ( response ) in
            //=============暫時方案===================================================
            if let reasons = response.error?.reasons {
                if let errors = reasons["errors"] as? [String: Any] {
                    if errors["email"] != nil {
                        let alert = UIAlertController(title: nil, message: "信箱格式錯誤或已註冊", preferredStyle: .alert)
                        let action = UIAlertAction(title: "確認", style: .default)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: nil, message: "帳號已存在", preferredStyle: .alert)
                        let action = UIAlertAction(title: "確認", style: .default)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        print("check", response)
                    }
                }
            }
            //======================================================
        }
    }
    //登入
    func login(userLogin: String, password: String) {
        SVProgressHUD.show(withStatus: "Logining to rest")
        QBRequest.logIn(withUserLogin: userLogin, password: password, successBlock: { _, user in
            SVProgressHUD.show(withStatus: "Connecting to chat")
            QBChat.instance.connect(with: user) { _ in
                self.performSegue(withIdentifier: "NEWHOME", sender: user)
                SVProgressHUD.dismiss()
            }}, errorBlock: { _ in
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "錯誤", message: "帳號密碼錯誤", preferredStyle: .alert)
                let action = UIAlertAction(title: "確認", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
        }
        )
    }
    //新增新用戶資料 in firebase
    var ref: DatabaseReference?
    func addUser(user: [String: Any]) {
        ref = Database.database().reference()
        ref?.child("user").childByAutoId().setValue(user)
    }
    //傳資料
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let homeVC  = segue.destination as? HomeViewController else { return } //handle error
        homeVC.currentUser = sender as? QBUUser
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
