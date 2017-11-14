//  CameraImgPreVC.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-10-10.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import AVFoundation
import Firebase

class ImagePreVC: UIViewController {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var addTextField: UITextField!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(String(describing: Auth.auth().currentUser?.uid))")
        
        photo.image = self.image
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func postButton(_ sender: Any) {
        UploadImageToFirebase()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func addTextButton(_ sender: Any) {
        addTextField.isHidden = false
    }
    
    @IBAction func saveLocalButton(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("\n Image saved to local library. \n")
        let alert = UIAlertController(title: "Hurra!", message: "Bilden sparades på din telefon!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func UploadImageToFirebase() {
        let uid = Auth.auth().currentUser?.uid
        let database = Database.database().reference()
        let storage = Storage.storage().reference().child("images").child(uid!)
        let key = database.child("Posts").childByAutoId().key
        let imageRef = storage.child("\(key)")
        let imageRef256 = storage.child("\(key)256")
        let resizedImage = self.resizeImage(image: image!, targetSize: CGSize.init(width: 256, height: 256))
        
        //Bild i liten storlek
        if let imageData256 = UIImagePNGRepresentation(resizedImage) {
            let uploadTask = imageRef256.putData(imageData256, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                let secondURL = metadata?.downloadURL()?.absoluteString
                if secondURL != nil {
                    let feed = ["userID" : uid!,
                                "date": [".sv": "timestamp"],
                                "pathToImage256" : secondURL!,
                                "likes" : 0,
                                "alias" : Auth.auth().currentUser?.displayName as Any,
                                "imgdescription" : self.addTextField.text!,
                                "postID" : key] as [String : Any]
                    let postFeed = ["\(key)" : feed]
                    database.child("Posts").updateChildValues(postFeed)
                } else {
                    print("\n Could not allocate URL for resized image. \n")
                }
            })
            uploadTask.resume()
        }
        
        //Bild i full storlek (denna uploadTask läggs sist eftersom denna blir färdig sist)
        if let imageData = UIImageJPEGRepresentation(image!, 0.6) {
            let uploadTask = imageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                let firstURL = metadata?.downloadURL()?.absoluteString
                if firstURL != nil {
                    let feed = ["pathToImage" : firstURL!] as [String : Any]
                    database.child("Posts").child("\(key)").updateChildValues(feed)
                } else {
                    print("\n Could not allocate URL for full size image. \n")
                }
            })
            uploadTask.resume()
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
