//  RegisterVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-09-14.
//  Copyright © 2017 Nicklas Gilbertson. All rights reserved.

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth


class RegisterVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repassword: UITextField!
    @IBOutlet weak var showPass: UIButton!
    @IBOutlet weak var infoViewOutlet: UIView!
    
    var infoStartValue : CGFloat = 0.0
    var infoOpen = false
    
    @IBAction func infoViewClick(_ sender: Any) {
        if infoOpen == false {
            infoViewOutlet.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.infoViewOutlet.frame.origin.y = self.infoStartValue
            }, completion: nil)
            infoOpen = true
        }else {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.infoViewOutlet.frame.origin.y = 500
            }, completion: { (complete: Bool) in
                self.infoViewOutlet.isHidden = true
                self.infoOpen = false
            })
            
        }
       
    }
    
    var clicks = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        infoViewOutlet.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        infoStartValue = infoViewOutlet.frame.origin.y
        print(infoStartValue)
        infoViewOutlet.frame.origin.y = 500
    }
    
    
    @IBAction func Register(_ sender: Any) {
        
        if password.text != repassword.text {
            self.createAlertLogin(title: "Inte samma", message: "Lösenorden du skrev överensstämmer inte, vänligen försök igen")
            self.password.text = ""
            self.repassword.text = ""
            self.password.becomeFirstResponder()
            return
        }
        
        Auth.auth().createUser(withEmail: mail.text!, password: password.text!, completion: {
//            user, error in
//
//            if error != nil {
//                self.login()
//            }
//            else {
//
//                print ("User created")
//                self.login()
//            }
            (user, error) in
            if error != nil {
                print("fel vid signup")
                
                if (self.password.text?.count)! < 7 {
                    print("lösenord är mindre än 5")
                    self.createAlertLogin(title: "Lösenord", message: "Ditt lösenord måste vara mer fler än 5 tecken")
                }
                self.password.text = ""
                self.repassword.text = ""
                
                self.createAlertLogin(title: "Problem", message: "Något problem uppstod, vänligen försök igen")
                
            } else {
                print("OK signup")
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if mail.isEditing == true {
            self.password.becomeFirstResponder()
            return true
        } else if password.isEditing == true {
            self.repassword.becomeFirstResponder()
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
