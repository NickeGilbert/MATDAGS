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
        let dbref = db.reference(withPath: "Users/\(uid)/MyBlockedUsers")
        let ubref = db.reference(withPath: "Users/\(userId)/UsersThatBlockedMe")
     
        if self.posts[0].postID != nil {
            let blockedUser = ["\(self.posts[0].alias!)" : "\(userId)" ] as [String : Any]
            let  blockedBy = ["\(String(describing: alias!))" : "\(uid)" ] as [String : Any]
      
            ubref.updateChildValues(blockedBy)
            dbref.updateChildValues(blockedUser)
            
            checkMyBlockedUsers()
            unfollowBlockedUser()
           
        } else {
            return
        }
    }
    
    func checkMyBlockedUsers() {
        if uid != nil {
            db.reference(withPath: "Users/\(uid)/MyBlockedUsers").observeSingleEvent(of: .value) { (snapshot) in
                
                if let dict = snapshot.value as? [String : AnyObject] {
                    for uid in dict {
                        let appendUser = User()                        
                        appendUser.uid = uid.value as? String
                        self.myBlockedUsers.append(appendUser.uid)
                        self.unfollowBlockedUser()
                        
                    }
                }
            }
        }
    }
    
    func unfollowBlockedUser() {
        for user in self.userFollowing {
            if self.myBlockedUsers.contains(user) {
                unfollowUser()
            } else {
            }
        }
    }
} //

extension ImageFeedVC {
    func getMyBlockedUsers() {
        if uid != nil {
            db.reference(withPath: "Users/\(uid!)/MyBlockedUsers").observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String : AnyObject] {
                    for uid in dict {
                        let appendUser = User()
                        appendUser.uid = uid.value as? String
                        self.myBlockedUsers.append(appendUser.uid)
                    }
                }
            }
        }
    }
}
