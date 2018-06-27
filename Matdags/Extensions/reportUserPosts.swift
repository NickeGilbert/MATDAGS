//
//  reportUser.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-05-25.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit
import Firebase

extension ImagePageVC {
    
    func reportPost() {
        if reports <= 4 {
            let ref = Database.database().reference(withPath: "Posts/\(seguePostID)")
            reports = reports+1
            let myReports = ["Reports" : reports ] as [String : Int]
            ref.updateChildValues(myReports)
            addUserIDToPostReportInPOST()
        } else {
            self.deletePosts()
        }
        
    }
    
    func reportPostSecond() {
        if reportsOnUsers <= 5 {
            let userPostUID = self.posts[0].userID
            let ref = Database.database().reference().child("Users").child(userPostUID!).child("Posts").child(seguePostID)
            reportsOnUsers = reportsOnUsers+1
            let myReports = ["Reports" : reportsOnUsers ] as [String : Int]
            ref.updateChildValues(myReports)
            addUserIDToPostReportInUSER()
        } else {
            let userPostUID = self.posts[0].userID
            let myRef = Database.database().reference().child("Users").child(userPostUID!).child("Posts").child(seguePostID)
            myRef.removeValue { (error, ref) in
                if error != nil {
                    print("DIDN'T GO THROUGH")
                    return
                }
            }
        }
    }
    
    func checkHowManyReportsUserpostHave() {
        let ref = Database.database()
        ref.reference(withPath: "Posts/\(seguePostID)").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.reports = value?["Reports"] as? Int ?? -1
        })
    }
    
    func addUserIDToPostReportInPOST() {
        let ref = Database.database().reference(withPath: "Posts/\(seguePostID)/UsersThatHaveReportedThisImage")
        let userThatReportedYou = [ alias! : uid ] as [String : AnyObject]
        ref.updateChildValues(userThatReportedYou)
    }
    
    func addUserIDToPostReportInUSER() {
        let userPostUID = self.posts[0].userID
        let ref = Database.database().reference(withPath: "Users/\(userPostUID!)/Posts/\(seguePostID)/UsersThatHaveReportedThisImage")
        let userThatReportedYou = [ alias! : uid ] as [String : AnyObject]
        ref.updateChildValues(userThatReportedYou)
        
    }
    
    func checkIfUserAlreadyHaveReportedThisImage() {
        Database.database().reference(withPath: "Posts/\(seguePostID)/UsersThatHaveReportedThisImage").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                for uidValue in dict {
                    let appendUser = User()
                    appendUser.uid = uidValue.value as? String
                    self.arrayOfUsersThatHaveReportedAnImage.append(appendUser.uid)
                }
            }
        })
    }
    
    func checkForUIDInReportedImage() {
        for user in arrayOfUsersThatHaveReportedAnImage {
            if uid == user {
                return
            }
        }
        reportPost()
        reportPostSecond()
    }
}
