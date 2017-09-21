//  RegisterViewController.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-09-14.
//  Copyright © 2017 Nicklas Gilbertson. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet var mail: UITextField!
    
    @IBOutlet var password: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func registerAccount(_ sender: Any) {
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
    
    func login(){
        Auth.auth().signIn(withEmail: mail.text!, password: password.text!, completion: {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
