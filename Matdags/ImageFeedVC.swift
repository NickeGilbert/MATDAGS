//  ImageFeedVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-09-15.
//  Copyright © 2017 Nicklas Gilbertson. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth

class ImageFeedVC: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

    }
    
    @IBAction func loggaOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            performSegue(withIdentifier: "logout", sender: nil)
            print("Logged out!")
        } catch {
            print("ERROR2")
        }
    }
}

extension ImageFeedVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func cameraButton(_ sender: Any) {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        imgPicker.sourceType = UIImagePickerControllerSourceType.camera
        
        self.present(imgPicker, animated: true, completion: nil)
    }
}
