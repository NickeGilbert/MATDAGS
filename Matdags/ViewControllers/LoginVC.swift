//  ViewController.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-09-21.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

class LoginVC: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {

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
        
        if FBSDKAccessToken.current() != nil {
            fetchProfile()
        }
        
        if (Auth.auth().currentUser != nil && Auth.auth().currentUser?.isEmailVerified == true && FBSDKAccessToken.current() == nil) {
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
                print("\n \(error!) \n")
                return
            }
            self.FBdata = result
            let request = FBSDKGraphRequest(graphPath:"me", parameters:nil)
            
            request!.start { (connection, result, error) in
                if error != nil {
                    print("\n \(error!) \n")
                } else if let userData = result as? [String:AnyObject] {
                    let username = userData["name"] as? String
                    print(username!)
                }
            }
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        AppDelegate.instance().showActivityIndicator()
        if error != nil {
            print("\(error)")
            AppDelegate.instance().dismissActivityIndicator()
            return
        } else {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signIn(with: credential) { (user, error) in
                if error != nil {
                    try! Auth.auth().signOut()
                    print("\n \(error!) \n")
                    self.createAlertLogin(title: facebookLoginTitle, message: facebookLoginMessage)
                    AppDelegate.instance().dismissActivityIndicator()
                    return
                } else {
                    self.performSegue(withIdentifier: "HomeToFeed", sender: AnyObject.self)
                    self.fetchProfile()
                    self.checkFirebaseInfo(arg: true, completion: { (success) -> Void in
                        if success {
                            self.createFirebaseUser()
                        } else {
                            print("\nAnvändaren finns redan så inget skickades till databasen!")
                        }
                    })
                    print("\nInloggad med Facebook.")
                    AppDelegate.instance().dismissActivityIndicator()
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
    
    @IBAction func loginButton(_ sender: Any) {
        login()
        password.resignFirstResponder()
    }
    
    func login() {
        AppDelegate.instance().showActivityIndicator()
        Auth.auth().signIn(withEmail: emailText.text!, password: password.text!, completion: { user, error in
            if error != nil{
                self.createAlertLogin(title: mailLoginErrorTitle, message: mailLoginErrorMessage)
                print("\n \(error!) \n")
                self.createAlertLogin(title: mailLoginProblemTitle, message: mailLoginProblemMessage)
                AppDelegate.instance().dismissActivityIndicator()
            } else {
                self.checkFirebaseInfo(arg: true, completion: { (success) -> Void in
                    if success {
                        if (Auth.auth().currentUser?.isEmailVerified == true) {
                            self.createFirebaseUser()
                            self.performSegue(withIdentifier: "HomeToFeed", sender: AnyObject.self)
                        } else {
                            self.createAlertLogin(title: verifyTitle, message: verifyMessage)
                            AppDelegate.instance().dismissActivityIndicator()
                        }
                    } else {
                        print("\n Användaren finns redan så inget skickades till databasen! \n")
                        self.performSegue(withIdentifier: "HomeToFeed", sender: AnyObject.self)
                    }
                })
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
            return true
        }
    }
}



