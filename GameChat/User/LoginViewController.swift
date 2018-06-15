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

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "FunChat"
        setBackgroundImage()
        setButtonUI()
        autoLogin()
    }

    func setButtonUI() {
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 5.0
        signupButton.layer.masksToBounds = true
        signupButton.layer.cornerRadius = 5.0
        forgotButton.layer.masksToBounds = true
        forgotButton.layer.cornerRadius = 5.0
    }

    func setBackgroundImage() {
        UIGraphicsBeginImageContext(view.frame.size)
        var image = UIImage(named: "LOGIN")
        image?.draw(in: view.bounds)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        view.backgroundColor = UIColor(patternImage: image!)
    }

    @IBAction func didLogin(_ sender: UIButton) {

        if let userId = idTextField.text {
            if let password = passwordTextField.text {
                if !userId.isEmpty {
                    if !password.isEmpty {
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

    func autoLogin() {
        if let userlogin = UserDefaults.standard.value(forKey: "login") as? String {
            if let userpassword = UserDefaults.standard.value(forKey: "password") as? String {
                idTextField.isHidden = true
                passwordTextField.isHidden = true
                loginButton.isHidden = true
                signupButton.isHidden = true
                forgotButton.isHidden = true
                login(userLogin: userlogin, password: userpassword)
            } else { print("還沒登入過") } //handle error
        } else { print("還沒登入過") } //handle error
    }

    func login(userLogin: String, password: String) {
        SVProgressHUD.show(withStatus: "登入中")
        QBRequest.logIn(withUserLogin: userLogin, password: password, successBlock: { _, user in
            SVProgressHUD.show(withStatus: "獲取使用者資料")
            UserDefaults.standard.set(userLogin, forKey: "login")
            UserDefaults.standard.set(password, forKey: "password")
            QBChat.instance.connect(with: user) { _ in
                self.performSegue(withIdentifier: "GOHOME", sender: user)
                SVProgressHUD.dismiss()
            }

            },
            errorBlock: { _ in
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "錯誤", message: "帳號密碼錯誤", preferredStyle: .alert)
                let action = UIAlertAction(title: "確認", style: .default)
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === idTextField {

            guard let userNameText = idTextField.text else { return true }

            let userNameTextlenth = userNameText.count + string.count - range.length

            let isValue = userNameTextlenth <= 12

            return isValue

        } else {
            return true
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
