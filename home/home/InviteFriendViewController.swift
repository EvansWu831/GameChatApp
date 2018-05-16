//
//  InviteFriendViewController.swift
//  home
//
//  Created by Evans Wu on 2018/5/15.
//  Copyright © 2018年 Evans Wu. All rights reserved.
//

import Foundation
import UIKit

protocol InviteFriendDelegate:class {
    func manager(_ manager: InviteFriendViewController, didFetch ids: [NSNumber])
}

class InviteFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var inviteFriendTableview: UITableView!
    
    let ids:[NSNumber] = [49401588, 49401608, 49401615, 49401640]
    
    var inviteIds: [NSNumber] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ids.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = inviteFriendTableview.dequeueReusableCell(withIdentifier: "INVITE_CELL", for: indexPath) as! InviteFriendTableViewCell
        let id = ids[indexPath.row]
        cell.textLabel?.text = "\(id)"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            if let id = inviteIds.index(of: ids[indexPath.row]) {
            inviteIds.remove(at: id)
            }
            else
            {
                print("取消時發生錯誤")
                return
            }
        }
        else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            inviteIds.append(ids[indexPath.row])
        }
    }
    
    weak var delegate: InviteFriendDelegate?
    
    @IBAction func backToHome(_ sender: UIButton) {
        
        self.delegate?.manager(self, didFetch: inviteIds)
        
        print(inviteIds)
        
        self.navigationController?.popViewController(animated: true)
        
    }
}
