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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mail.delegate = self
        password.delegate = self
        repassword.delegate = self
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func closeRegisterButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func Register(_ sender: Any) {
        
        if password.text != repassword.text {
            print("Please re-enter correct password")
            createAlertRegister(title: "Stämmer inte överrens", message: "Lösenorden måste vara identiska")
            return
        }
        
        Auth.auth().createUser(withEmail: mail.text!, password: password.text!, completion: {
            user, error in
            
            if self.password.text!.count <= 4 {
                self.createAlertRegister(title: "Lösenordslängd", message: "Lösenordet måste vara längre än 5 tecken, vänligen försök igen")
            }
            
            if error != nil {
                self.createAlertRegister(title: "Problem", message: "Något problem uppstod, vänligen försök igen")
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
                self.createAlertRegister(title: "Problem", message: "Ett inloggningsproblem uppstod, vänligen försök igen")
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
    
    func createAlertRegister (title:String, message:String) {
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
