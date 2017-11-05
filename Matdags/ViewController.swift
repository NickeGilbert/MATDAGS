//  ViewController.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-09-21.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet var emailText: UITextField!
    @IBOutlet var password: UITextField!
    var FBdata : Any?
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailText.delegate = self
        password.delegate = self
        
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func fetchProfile() {
        
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            self.FBdata = result
//            print(String(describing: result!))
            // Create request for user's Facebook data
            let request = FBSDKGraphRequest(graphPath:"me", parameters:nil)
            
            // Send request to Facebook
            request!.start {
                
                (connection, result, error) in
                
                if error != nil {
                    // Some error checking here
                }
                else if let userData = result as? [String:AnyObject] {
                    
                    // Access user data
                    let username = userData["name"] as? String
                    print(username!)
                    
                    // ....
                }
            }
            
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    self.createAlertLogin(title: "Problem", message: "Något inloggningsproblem uppstod, vänligen försök igen")
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
                self.createAlertLogin(title: "Problem", message: "Något inloggningsproblem uppstod, vänligen försök igen")
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if emailText.isEditing == true {
            self.password.becomeFirstResponder()
            return true
        } else {
            self.view.endEditing(true)
            login()
            return true
        }
        
    }
    
    func createAlertLogin (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            action in
            alert.dismiss(animated: true, completion: nil)
            // Fler saker här för att köra mer kod
        }))
        //        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
        //            action in
        //            alert.dismiss(animated: true, completion: nil)      SKAPA UPP FLER AV DESSA FÖR FLERA VAL
        //        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}

