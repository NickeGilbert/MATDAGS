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

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if Auth.auth().currentUser?.uid != nil {
            goHome()
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
                self.goHome()
                print("Correct")
            }
        })
    }
    
    func goHome() {
        let homePage = ImageFeedVC()
        self.present(homePage, animated: true,
                     completion: nil) //Denna koden stämmer inte, ska kolla senare
    }
}

