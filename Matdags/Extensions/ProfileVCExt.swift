//
//  ProfileVCExt.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-06-19.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit
import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
import AVFoundation

extension ProfileVC {
    func deleteUser() {
        let database = Database.database().reference(withPath: "Posts")
    //    let usrdatabase = Database.database().reference(withPath: "Users")
        let storage = Storage.storage().reference().child("images").child(uid!)
        let key = database.childByAutoId().key
      //  let imageRef = storage.child("\(key)")
        
        if(FBSDKAccessToken.current() == nil) {
            
          //  var ref = DatabaseReference()
            let user = Auth.auth().currentUser
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            //ref = Database.database().reference()
            
            ref.child("Users/\(uid)").removeValue(completionBlock: { (error, ref) -> Void in
                if error == nil {
                    self.deleteFbAuthFromFirebase()
                    self.IdOfAllOfMyPosts()
                    print(ref)
                } else{
                }
            })
            
            Auth.auth().currentUser?.delete(completion: { (error) in
                if let error = error {
                } else {
                }
            })
            
            user?.delete { error in
                if let error = error {
                } else {
                }
            }
            
            let userID = Auth.auth().currentUser?.uid
            let currenUserRef = Database.database().reference().child("users/\(userID)").child(userID!)
            currenUserRef.observe(.value, with: { (snapshot) in
            })
            
            self.logOutFromApp()
            
        } else {
            //FÖR FACEBOOK
          //  var Useruid = Auth.auth().currentUser?.uid
            var ref = DatabaseReference()
           // let user = Auth.auth().currentUser
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
          //  ref = Database.database().reference()
            
            ref.child("Users/\(uid)").removeValue(completionBlock: { (error, ref) -> Void in
                if error == nil {
                    self.deleteFbAuthFromFirebase()
                    self.IdOfAllOfMyPosts()
                    print(ref)
                }else{
                }
            })
            //key är inte rätt
            ref.child("Posts/\(key)/\(uid)").removeValue(completionBlock: { (error, ref) -> Void in
                if error == nil {
                    self.IdOfAllOfMyPosts()
                    print(ref, "TA BORT ANVÄNDARENS POSTS")
                }else{
                    
                }
            })
        }
        Auth.auth().currentUser?.delete(completion: { (error) in
            if let error = error {
                
            } else {
            }
        })
        self.logOutFromApp()
    }
    
    func deleteFbAuthFromFirebase(){
        let user = Auth.auth().currentUser
       // let id = user?.uid
        user?.delete { error in
            if let error = error {
                print(error)
            } else {
            }
        }
    }
    
    func logOutFromApp() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let loginManager = FBSDKLoginManager()
            loginManager.logOut() // this is an instance function
            self.performSegue(withIdentifier: "profileLogout", sender: nil)
            print(" \n DU HAR PRECIS LOGGAT UT \n")
        } catch {
            print("\n ERROR NÄR DU LOGGADE UT \n")
        }
    }
}
