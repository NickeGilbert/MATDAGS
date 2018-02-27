//
//  CreatedAlertsExt.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-01-20.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

extension UIViewController {
    
    func createAlertLogin (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{ action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createAlertRegister (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{ action in
            self.performSegue(withIdentifier: "loggaIn", sender: AnyObject.self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
 
    func deleteAccountAlert (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "JA", style: UIAlertActionStyle.default, handler:{ action in
            
            let uid = Auth.auth().currentUser?.uid
            let database = Database.database().reference(withPath: "Posts")
            let usrdatabase = Database.database().reference(withPath: "Users")
            let storage = Storage.storage().reference().child("images").child(uid!)
            let key = database.childByAutoId().key
            let imageRef = storage.child("\(key)")
           
            if(FBSDKAccessToken.current() == nil) {
               
                var ref = DatabaseReference()
                let user = Auth.auth().currentUser
                guard let uid = Auth.auth().currentUser?.uid else {
                    return
                }
                
                ref = Database.database().reference()
                
                ref.child("Users/\(uid)").removeValue(completionBlock: { (error, ref) -> Void in
                    if error == nil {
                        self.deleteFbAuthFromFirebase()
                        allOfMyPosts()
                        print(ref)
                    } else{

                    }
                }
            )
     
                Auth.auth().currentUser?.delete(completion: { (error) in
                    if let error = error {
                        
                    } else {
                        
                    }
                })
 
                user?.delete { error in
                    if let error = error {
                        // An error happened.
                    } else {
                        // Account deleted.
                    }
                }
                
                let userID = Auth.auth().currentUser?.uid
                let currenUserRef = Database.database().reference().child("users/\(userID)").child(userID!)
                currenUserRef.observe(.value, with: { (snapshot) in
                   
                })
                
                self.logOutFromApp()
                
            } else {
                //FÖR FACEBOOK
                    var Useruid = Auth.auth().currentUser?.uid
                    var ref = DatabaseReference()
                    let user = Auth.auth().currentUser
                    guard let uid = Auth.auth().currentUser?.uid else {
                        return
                    }
                    
                    ref = Database.database().reference()
                    
                    ref.child("Users/\(uid)").removeValue(completionBlock: { (error, ref) -> Void in
                        if error == nil {
                            self.deleteFbAuthFromFirebase()
                            allOfMyPosts()
                            print(ref)
                        }else{

                        }
                    }
                    )
                
                    ref.child("Posts/\(key)/\(uid)").removeValue(completionBlock: { (error, ref) -> Void in
                        if error == nil {
                            allOfMyPosts()
                            print(ref, "TA BORT ANVÄNDARENS POSTS")
                        }else{

                        }
                    }
                )
            }
            
            func allOfMyPosts() {
                let dbref = Database.database().reference().child("Posts/\(key)")
                dbref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let tempSnapshot = snapshot.value as? [String : AnyObject] {
                        for (_, each) in tempSnapshot {
                            let getUser = User()
                            getUser.postID = each["postID"] as? String
                            print("\(each) MINA POSTS ")

                        }
                    }
                })
            }
            
                Auth.auth().currentUser?.delete(completion: { (error) in
                    if let error = error {
                        
                    } else {
                    }
                })

            self.logOutFromApp()
            
        }))
        
        alert.addAction(UIAlertAction(title: "NEJ", style: UIAlertActionStyle.default, handler:{ action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteFbAuthFromFirebase(){
        let user = Auth.auth().currentUser
        let id = user?.uid
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
