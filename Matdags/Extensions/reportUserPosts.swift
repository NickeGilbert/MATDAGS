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
            let ref = Database.database().reference().child("Posts").child(seguePostID)
            if self.posts[0] != nil {
                
                
                reports = reports+1
                let myReports = ["Reports" : reports ] as [String : Int]
                ref.updateChildValues(myReports)
                addUserIDToPostReportInPOST()
            } else {
                print("Did not work")
            }
        } else {
            self.deletePosts()
        }
        
    }
    
    func reportPostSecond() {
        if reportsOnUsers <= 5 {
            let userPostUID = self.posts[0].userID
            let ref = Database.database().reference().child("Users").child(userPostUID!).child("Posts").child(seguePostID)
            if self.posts[0] != nil {
                
                reportsOnUsers = reportsOnUsers+1
                let myReports = ["Reports" : reportsOnUsers ] as [String : Int]
                ref.updateChildValues(myReports)
                addUserIDToPostReportInUSER()
            } else {
                print("Did not work")
            }
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
        let ref = Database.database().reference()
        ref.child("Posts").child(seguePostID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            self.reports = value?["Reports"] as? Int ?? -1
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func addUserIDToPostReportInPOST() {
        let ref = Database.database().reference().child("Posts").child(seguePostID).child("UsersThatHaveReportedThisImage")
        let userThatReportedYou = [ alias! : uid ] as [String : AnyObject]
        ref.updateChildValues(userThatReportedYou)
   
    }
    
    func addUserIDToPostReportInUSER() {
        let userPostUID = self.posts[0].userID
        let ref = Database.database().reference().child("Users").child(userPostUID!).child("Posts").child(seguePostID).child("UsersThatHaveReportedThisImage")
        let userThatReportedYou = [ alias! : uid ] as [String : AnyObject]
        ref.updateChildValues(userThatReportedYou)
        
    }
    
    func checkIfUserAlreadyHaveReportedThisImage() {
        _ =  Database.database().reference().child("Posts").child(seguePostID).child("UsersThatHaveReportedThisImage").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if (snapshot.value as? NSDictionary) != nil {
                let value = snapshot.value as! NSDictionary
                for uidValue in value {
                    let appendUser = User()
                    appendUser.uid = uidValue.value as? String
                    self.myReportsTestArray.append(appendUser.uid)
                    
                }
            } else {
                return
            }
        })
    }
    
    func checkForUIDInReportedImage() {
        for user in myReportsTestArray {
            if uid == user {
                return
            } else {
            }
        }
        reportPost()
        reportPostSecond()
    }
}
