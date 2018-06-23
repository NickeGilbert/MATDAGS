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
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mail.delegate = self
        alias.delegate = self
        password.delegate = self
        repassword.delegate = self
        
        mail.placeholder = NSLocalizedString("emailPlaceholder", comment: "")
        alias.placeholder = NSLocalizedString("usernamePlaceholder", comment: "")
        password.placeholder = NSLocalizedString("passwordPlaceholder", comment: "")
        repassword.placeholder = NSLocalizedString("rePasswordPlaceholder", comment: "")
        showPass.setTitle(NSLocalizedString("showPasswordPlaceholder", comment: ""), for: .normal)
        registerButton.setTitle(NSLocalizedString("registerButton", comment: ""), for: .normal)
        infoButton.setTitle(NSLocalizedString("infoButton", comment: ""), for: .normal)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func closeRegisterButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Register(_ sender: Any) {
        if mail.text == "" {
            self.createAlertRegister(title: emptyMail, message: emptyMailMessage)
            return
        }
        if password.text != repassword.text {
            createAlertRegister(title: passwordTitle, message: passwordMessage)
            return
        }
        if alias.text == "" {
            self.createAlertRegister(title: username , message: usernameMessage)
            return
        }
        
        Auth.auth().createUser(withEmail: mail.text!, password: password.text!, completion: { user, error in
            if error != nil {
                print("\n \(error!) \n")
                self.createAlertRegister(title: errorTitle, message: errorMessage)
                return
            }
            if self.password.text!.count <= 4 {
                self.createAlertRegister(title: passwordLenghtTitle, message: passwordLenghtMessage)
                return
            } else {
                if let userC = user {
                    let changeRequest = userC.createProfileChangeRequest()
                    changeRequest.displayName = self.alias.text!
                    changeRequest.commitChanges(completion: nil)
                }
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    print("\n BEKRÄFTELSEMAIL  \n")
                    
                self.createAlertRegister(title: validateTitle, message: validateMessage)
                }
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
    
    @IBAction func infoClick(_ sender: Any) {
        createAlertRegister(title: infoTitle , message: infoMessage )
    }
}
