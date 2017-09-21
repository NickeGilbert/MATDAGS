//  ViewController.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-09-21.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet var emailText: UILabel!
    
    @IBOutlet var password: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser?.uid != nil {
            goHome()
        }
        // Do any additional setup after loading the view, typically from a nib.
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
        let bildflodeVC = bildflodeViewController()
        self.present(bildflodeVC, animated: true,
                     completion: nil)
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

