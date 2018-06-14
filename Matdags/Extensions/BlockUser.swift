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
        
     
        if self.posts[0].userID != nil {
            let blockedUser = ["\(self.posts[0].alias!)" : "\(userId)" ] as [String : Any]
            
            let  blockedBy = ["\(String(describing: alias!))" : "\(uid)" ] as [String : Any]
            
            ubref.updateChildValues(blockedBy)
            dbref.updateChildValues(blockedUser)
        } else {
            return
        }
    }
}

extension ImageFeedVC {
    func getMyBlockedUsers() {
        let dbref = db.reference(withPath: "Users/\(uid)/MyBlockedUsers").observeSingleEvent(of: .value) { (snapshot) in

            if (snapshot.value as? NSDictionary) != nil {
                let value = snapshot.value as! NSDictionary
                for uidValue in value {
                    let appendUser = User()
                    appendUser.uid = uidValue.value as? String
                    self.myBlockedUsers.append(appendUser.uid)
                    print("MY BLOCKED USERS:", self.myBlockedUsers)
                }
            }
            self.checkMyBlockedUsers()
        }
        
    }
    
    func checkMyBlockedUsers() {
//        for user in myBlockedUsers {
//            print("USERS BLOCKED:", user)
//        }
//
//        ref.child("Posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
//            if let postsSnap = snap.value as? [String: AnyObject] {
//                for (_,post) in postsSnap {
//                    if let userID = post["userID"] as? String {
//                        for each in self.myBlockedUsers {
//                            if each == userID {
//                                let appendPost = Post()
//
//                                appendPost.date = post["date"] as? String
//                                appendPost.alias = post["alias"] as? String
//                                appendPost.rating = post["rating"] as? Double
//                                appendPost.pathToImage = post["pathToImage"] as? String
//                                appendPost.postID = post["postID"] as? String
//                                appendPost.vegi = post["vegetarian"] as? Bool
//                                appendPost.usersRated = post["usersRated"] as? Double
//
//                                //self.posts.append(appendPost)
//
//
//                            }
//                        }
//                    }
//                }
//            } else {
//                print("\nNo Posts found in db.")
//            }
//        })
//    }
    
//    func getUsersThatBlockedMe() {
//        let dbref = db.reference(withPath: "Users/\(uid)/UsersThatBlockedMe").observeSingleEvent(of: .value) { (snapshot) in
//
//            if (snapshot.value as? NSDictionary) != nil {
//                let value = snapshot.value as! NSDictionary
//                for uidValue in value {
//                    let appendUser = User()
//                    appendUser.uid = uidValue.value as? String
//                    self.usersThatBlockedMe.append(appendUser.uid)
//
//                }
//            }
//        }
//    }
    
    }
}
