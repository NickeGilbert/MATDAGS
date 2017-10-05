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
                self.dismiss(animated: true, completion: nil)
                print("Correct")
            }
        })
    }
}

