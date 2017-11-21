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
    @IBOutlet weak var alias: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repassword: UITextField!
    @IBOutlet weak var showPass: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mail.delegate = self
        alias.delegate = self
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
        if mail.text == "" {
            self.createAlertRegister(title: "Mailadress", message: "Du måste ange en mailadress")
            return
        }
        if password.text != repassword.text {
            print("Please re-enter correct password")
            createAlertRegister(title: "Stämmer inte överrens", message: "Lösenorden måste vara identiska")
            return
        }
        if alias.text == "" {
            self.createAlertRegister(title: "Användarnamn", message: "Ditt användarnamn får inte vara tomt")
            return
        }
        Auth.auth().createUser(withEmail: mail.text!, password: password.text!, completion: { user, error in
            if self.password.text!.count <= 4 {
                self.createAlertRegister(title: "Lösenordslängd", message: "Lösenordet måste vara längre än 5 tecken, vänligen försök igen")
            }
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = self.alias.text!
            }
            if error != nil {
                print("\n \(error!) \n")
                self.createAlertRegister(title: "Problem", message: "Något problem uppstod, vänligen försök igen")
            } else {
              //  self.createFirebaseUser()
                print ("User created!")
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    print("\n BEKRÄFTELSEMAIL  \n")
                    
                self.createAlertRegister(title: "Okay", message: "Du måste gå och Validera ditt konto på din mail!")
                }
            }
        })
    }
    
    func login() {
        AppDelegate.instance().showActivityIndicator()
        
        Auth.auth().signIn(withEmail: mail.text!, password: password.text!, completion: { user, error in
            if error != nil{
                print ("\n Incorrect with error: \(error!) \n")
                self.createAlertRegister(title: "Problem", message: "Ett inloggningsproblem uppstod, vänligen försök igen")
            } else {
                self.performSegue(withIdentifier: "RegToFeed", sender: AnyObject.self)
                print("\n Correct \n")
                AppDelegate.instance().dismissActivityIndicator()
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
        } else {
            password.isSecureTextEntry = true
            repassword.isSecureTextEntry = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if mail.isEditing == true {
            self.alias.becomeFirstResponder()
            return true
        } else if alias.isEditing == true {
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
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{ action in
            self.performSegue(withIdentifier: "loggaIn", sender: AnyObject.self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
        
    @IBAction func infoClick(_ sender: Any) {
        createAlertRegister(title: "Användardata", message: "Informationen du ger ifrån dig genom att skapa ett konto med din mailadress, alias och lösenord varken delas till andra eller används av oss själva förutom för att möjliggöra inloggning med historik på flera enheter. ")
    }
    
  /*  func createFirebaseUser() {
        let uid = Auth.auth().currentUser!.uid
        let username = Auth.auth().currentUser!.displayName
        let useremail = Auth.auth().currentUser!.email
        let database = Database.database().reference(withPath: "Users/\(uid)")
        let feed = ["alias" : username!,
                    "date": [".sv": "timestamp"],
                    "email" : useremail!] as [String : Any]
        database.updateChildValues(feed)
    }*/
}
