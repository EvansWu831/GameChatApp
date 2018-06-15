//
//  InviteFriendDelegate.swift
//  home
//
//  Created by Evans Wu on 2018/5/21.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation

protocol InviteFriendDelegate: class {
    func manager(_ manager: InviteFriendViewController, didFetch ids: [NSNumber])
}
