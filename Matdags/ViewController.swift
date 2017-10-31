//  ViewController.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-09-21.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class ViewController: UIViewController {

    @IBOutlet var emailText: UITextField!
    
    @IBOutlet var password: UITextField!
    
    
    //KANSKE EN FUNGERANDE FACEBOOK SEGUE MEN JAG KAN INTE TESTA FÖR KAN INTE MITT LÖSEN :(
  /*  var fbLoginSuccess = false
    
    override func viewDidAppear(_ animated: Bool) {
        if (FBSDKAccessToken.current() != nil && fbLoginSuccess == true)
        {
            performSegue(withIdentifier: "HomeToFeed", sender: self)
        }
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("Facebook User Logged In")
        
        if ((error) != nil) {
            // Process error
            print(error)
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            fbLoginSuccess = true
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email") {
                // Do work
            }
        }
    }*/
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        
        loginButton.frame = CGRect(x: 65, y: 400, width: view.frame.width - 130, height: 50)
        
        if(Auth.auth().currentUser != nil){
            self.performSegue(withIdentifier: "HomeToFeed", sender: AnyObject.self)
        }
    }
    
    @IBAction func loginButton(_ sender: Any) {
        login()
    }
    
    func login(){
        Auth.auth().signIn(withEmail: emailText.text!, password: password.text!, completion: {
            user, error in
            
            if error != nil{
                print ("INCORRECT BUDDY")
            }
            else{
                self.performSegue(withIdentifier: "HomeToFeed", sender: AnyObject.self)
                print("CORRECT BUDDY")
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

