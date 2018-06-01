//
//  ForgotPasswordViewController.swift
//  GameChat
//
//  Created by Evans Wu on 2018/5/31.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation
import UIKit
import Quickblox

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setGoBackButton()
    }

    func setGoBackButton() {
        navigationItem.title = "忘記密碼"
        let backButton = UIBarButtonItem()
        backButton.image = #imageLiteral(resourceName: "GO_BACK")
        backButton.target = self
        backButton.action = #selector(goBack)
        self.navigationItem.leftBarButtonItem = backButton
    }

    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func sendEmail(_ sender: UIButton) {
        guard let email = emailTextField.text else {return}
        QBRequest.resetUserPassword(withEmail: email, successBlock: { (respone) in
            let alert = UIAlertController(title: "信件發送成功", message: "點擊quickblox的來信件跟改密碼", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }) { (error) in
            let alert = UIAlertController(title: "信件發送失敗", message: "此信箱不存在,請再確認一次信箱", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
