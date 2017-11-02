//  ViewController.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-09-21.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet var emailText: UITextField!
    @IBOutlet var password: UITextField!
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 65, y: 400, width: view.frame.width - 130, height: 50)
        loginButton.delegate = self
        
        if let token = FBSDKAccessToken.current() {
            fetchProfile()
        }
        
        if(Auth.auth().currentUser != nil){
            self.performSegue(withIdentifier: "HomeToFeed", sender: AnyObject.self)
        }
    }
    
    func fetchProfile() {
        
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            
            print(result)
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    // ...
                    return
                } else {
                    self.performSegue(withIdentifier: "HomeToFeed", sender: AnyObject.self)
                    self.fetchProfile()
                    print("INLOGGAD MED FACEBOOK")
                }
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("LOGOUT BUTTON FACEBOOK")
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

