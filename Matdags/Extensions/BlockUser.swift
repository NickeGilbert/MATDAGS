//
//  BlockUser.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-06-14.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit
import Firebase

extension ImagePageVC {
    func reportUsers() {
      
        let userId = self.posts[0].userID!
        let aRef = db.reference(withPath: "Users/\(uid)/MyBlockedUsers")
        let bRef = db.reference(withPath: "Users/\(userId)/UsersThatBlockedMe")
        
     
        if self.posts[0].postID != nil {
            let blockedUser = ["\(self.posts[0].alias!)" : "\(userId)" ] as [String : Any]
            
            let  blockedBy = ["\(String(describing: alias!))" : "\(uid)" ] as [String : Any]
            
            aRef.updateChildValues(blockedBy)
            bRef.updateChildValues(blockedUser)
        } else {
            return
        }
    }
}

extension ImageFeedVC {
    func getMyBlockedUsers() {
        if uid != nil {
            db.reference(withPath: "Users/\(uid!)/MyBlockedUsers").observeSingleEvent(of: .value) { (snapshot) in
                if (snapshot.value as? NSDictionary) != nil {
                    let value = snapshot.value as! NSDictionary
                    for uidValue in value {
                        let appendUser = User()
                        appendUser.uid = uidValue.value as? String
                        self.myBlockedUsers.append(appendUser.uid)
                        print("MY BLOCKED USERS:", self.myBlockedUsers)
                    }
                }
            }
        } else {
            
        }
    }
}
