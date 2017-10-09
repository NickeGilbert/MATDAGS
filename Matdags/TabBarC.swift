//  TabBarC.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-10-05.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth

class TabBarC : UITabBarController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        if(Auth.auth().currentUser?.uid == nil) {
            performSegue(withIdentifier: "login", sender: nil)
    }
        else{
            print("INLOGGAD2")
        }
    }
}
