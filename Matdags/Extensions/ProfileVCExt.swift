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
        print("Deleting user...")
    
        let userRef = db.child("Users/\(uid!)")
        
        fetchMyPosts { (true) in
            self.deleteData{ (true) in
                userRef.removeValue()
                print("User database successfully deleted!")
                self.authedUser!.delete()
                print("User authentication successfully deleted!")
                self.logOutFromApp()
            }
        }
    }
    
    func logOutFromApp() {
        let auth = Auth.auth()
        do {
            try auth.signOut()
            let loginManager = FBSDKLoginManager()
            loginManager.logOut() // this is an instance function
            self.performSegue(withIdentifier: "profileLogout", sender: nil)
            print("User successfully logged out!\n")
        } catch {
            print("Error on logging out user!\n")
        }
    }
}
