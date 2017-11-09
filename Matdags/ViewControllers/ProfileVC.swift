//  ProfileVC.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-10-05.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    var FBdata : Any?
    
    override func viewDidLoad() {
        resizeImage()
        profileNameLabel.text = ""
        if let token = FBSDKAccessToken.current() {
            fetchProfile()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func resizeImage(){
        profilePictureOutlet.layer.cornerRadius = profilePictureOutlet.frame.size.height / 2
        profilePictureOutlet.clipsToBounds = true
        self.profilePictureOutlet.layer.borderColor = UIColor.white.cgColor
        self.profilePictureOutlet.layer.borderWidth = 2
    }
    
    func fetchProfile() {
        // http://graph.facebook.com/67563683055/picture?type=square
        
//        FBSDKAccessToken.current().userID
        
        var profile_img_url = "http://graph.facebook.com/"+FBSDKAccessToken.current().userID+"/picture?type=square"
        print(profile_img_url)
        let parameters = ["fields": "email, name, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) -> Void in
            
            if error != nil {
                print("\n",error,"\n")
                return
            }
            
            let request = FBSDKGraphRequest(graphPath:"me", parameters:parameters)
            
            // Send request to Facebook
            request!.start {
                
                (connection, result, error) in
                
                if error != nil {
                    // Some error checking here
                }
                    
                else {
                    let fbRes = result as! NSDictionary
                    
                    print(fbRes)
                    self.profileNameLabel.text = fbRes.value(forKey: "name") as! String
//                    self.profilePictureOutlet.image = (URL: profile_img_url)
                    
                }
                
                
            }
            
        }
    }
}
