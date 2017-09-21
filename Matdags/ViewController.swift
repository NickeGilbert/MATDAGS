//  ViewController.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-09-21.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser?.uid != nil {
            goHome()
        }
        // Do any additional setup after loading the view, typically from a nib.
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
    
    @IBAction func logginButton(_ sender: Any) {
        login()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

