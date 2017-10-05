//
//  bildflodeViewController.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2017-09-15.
//  Copyright © 2017 Nicklas Gilbertson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ImageFeedVC: UIViewController {

    @IBAction func loggaOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            performSegue(withIdentifier: "logout", sender: nil)
        } catch {
            print("ERROR2")
        }
    }
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navTitle: UINavigationItem!
    
    override func viewDidLoad() {
        
       /* navTitle.title = "Matdags"
        
        self.navBar.setBackgroundImage(UIImage(), for: .default)
        //self.navBar.shadowImage = UIImage()
        self.navBar.isTranslucent = true*/
    }
}
