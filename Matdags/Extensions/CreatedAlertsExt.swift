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
            // Fler saker här för att köra mer kod
        }))
        //        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
        //            action in
        //            alert.dismiss(animated: true, completion: nil)      SKAPA UPP FLER AV DESSA FÖR FLERA VAL
        //        }))
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
            if(FBSDKAccessToken.current() == nil) {
                
                let user = Auth.auth().currentUser
 
                user?.delete { error in
                    if let error = error {
                        // An error happened.
                    } else {
                        // Account deleted.
                    }
                }
                let userID = Auth.auth().currentUser?.uid
                let currenUserRef = Database.database().reference().child("users").child(userID!)
                currenUserRef.observe(.value, with: { (snapshot) in
                    
                    Auth.auth().currentUser?.delete(completion: { (error) in
                        if error == nil {
                            
                        } else {
                            
                        }
                    })
                })
                
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
                
            } else {
                print("DU ÄR INLOGGAD PÅ FACEBOOK")
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: "NEJ", style: UIAlertActionStyle.default, handler:{ action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
  
    
    
    
    
    
    
    
    
    
    
    
}
