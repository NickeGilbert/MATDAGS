 //  RegisterVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-09-14.
//  Copyright © 2017 Nicklas Gilbertson. All rights reserved.

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class RegisterVC: UIViewController {
    
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repassword: UITextField!
    @IBOutlet weak var showPass: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    @IBAction func closeRegisterButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func Register(_ sender: Any) {
        
        if password.text != repassword.text {
            print("Please re-enter correct password")
            return
        }
        
        Auth.auth().createUser(withEmail: mail.text!, password: password.text!, completion: {
            user, error in
            
            if error != nil {
                self.login()
            }
            else {
                
                print ("User created")
                self.login()
            }
        })
    }

    func login() {
        Auth.auth().signIn(withEmail: mail.text!, password: password.text!, completion: {
            user, error in
            
            if error != nil{
                print ("Incorrect")
            }
            else{
                self.performSegue(withIdentifier: "RegToFeed", sender: AnyObject.self)
                print("Correct")
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func showPass(_ sender: Any) {
        
        showPass.isSelected = !showPass.isSelected
        if showPass.isSelected {
            password.isSecureTextEntry = false
            repassword.isSecureTextEntry = false
        }
        else {
            password.isSecureTextEntry = true
            repassword.isSecureTextEntry = true
        }

    }
}
