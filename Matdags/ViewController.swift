//  ViewController.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-09-21.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailText: UITextField!
    
    @IBOutlet var password: UITextField!
    
    var isConnected = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        
        loginButton.frame = CGRect(x: 16, y: 500, width: view.frame.width - 32, height: 50)
        
        
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
                print("fel vid LOGIN")
                self.createAlertLogin(title: "Problem", message: "Något problem hände när du försökte logga in, vänligen försök igen")
                self.password.text = ""
                print("Incorrect")
            }
            else{
                self.performSegue(withIdentifier: "HomeToFeed", sender: AnyObject.self)
                print("Correct")
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
    
    func createAlertLogin (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

