//
//  FirebaseTest.swift
//  GameChat
//
//  Created by Evans Wu on 2018/6/13.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class FirebaseTest {
    var initiatorID: NSNumber?
    var currentUserID: NSNumber?
    let reference = Database.database().reference()
    
    func setValue() {
        
        guard let initiatorID = initiatorID else { return }
        guard let currentUserID = currentUserID else { return }
            reference.child("room").child("\(initiatorID)").setValue(["\(currentUserID)": "\(currentUserID)"])
        
    }
}
