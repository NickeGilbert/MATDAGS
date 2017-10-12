//  ViewController.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-09-21.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet var emailText: UITextField!
    
    @IBOutlet var password: UITextField!
    
    var isConnected = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
                print ("Incorrect")
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
}

