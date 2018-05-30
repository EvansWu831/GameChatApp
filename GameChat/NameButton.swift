//
//  NameButton.swift
//  GameChat
//
//  Created by Evans Wu on 2018/5/30.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation
import UIKit

class NameButton: UIViewController {
    @IBOutlet weak var nameButton: UIButton!
    @IBAction func action(_ sender: UIButton) {

        let alert = UIAlertController(title: "更改暱稱", message: nil, preferredStyle: .alert)

        var nameTextField: UITextField?

        alert.addTextField { (textField) in
            textField.text = self.nameButton.titleLabel?.text
            nameTextField = textField
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            self.nameButton.titleLabel?.text = nameTextField?.text
        }))

        self.present(alert, animated: true, completion: nil)
    }
}
