//
//  ViewControllerVCExt.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-01-20.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
extension UIViewController {
   
    func checkFirebaseInfo(arg: Bool, completion: @escaping (Bool) -> ()) {
        let uid = Auth.auth().currentUser!.uid
        let db = Database.database().reference(withPath: "Users/\(uid)")
        db.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
    func createFirebaseUser() {
        if(FBSDKAccessToken.current() != nil) {
            let uid = Auth.auth().currentUser!.uid
            let username = Auth.auth().currentUser!.displayName
            let useremail = Auth.auth().currentUser!.email
            let database = Database.database().reference(withPath: "Users/\(uid)")
            print("\n \(uid) \n")
            print("\n \(username!) \n")
            print("\n \(useremail!) \n")
            if useremail == nil || username == nil {
                return
            }
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let result = formatter.string(from: date)
            let feed = ["followingCounter" : 0,
                        "followerCounter" : 0,
                        "alias" : username!,
                        "date" : result,
                        "uid" : uid,
                        "profileImageURL" : "http://graph.facebook.com/"+FBSDKAccessToken.current().userID+"/picture?type=large",
                        "email" : useremail!] as [String : Any]
            database.updateChildValues(feed)
            print("\n Firebase User Created! \n")
        } else {
            let uid = Auth.auth().currentUser!.uid
            let username = Auth.auth().currentUser!.displayName
            let useremail = Auth.auth().currentUser!.email
            let database = Database.database().reference(withPath: "Users/\(uid)")
            print("\n \(uid) \n")
            print("\n \(username!) \n")
            print("\n \(useremail!) \n")
            if useremail == nil || username == nil {
                return
            }
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let result = formatter.string(from: date)
            let feed = ["followingCounter" : 0,
                        "followerCounter" : 0,
                        "alias" : username!,
                        "date" : result,
                        "uid" : uid,
                        "profileImageURL" : "",
                        "email" : useremail!] as [String : Any]
            database.updateChildValues(feed)
            print("\n Firebase User Created! \n")
        }
    }
}
