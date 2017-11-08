//  CameraImgPreVC.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-10-10.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import AVFoundation
import Firebase

class ImagePreVC: UIViewController {
    
    @IBOutlet weak var photo: UIImageView!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(String(describing: Auth.auth().currentUser?.uid))")
        
        photo.image = self.image
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        UploadImageToFirebase()
        dismiss(animated: false, completion: nil)
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
                
                let feed = ["userID" : uid!,
                            "date": [".sv": "timestamp"],
                            "pathToImage256" : secondURL!,
                            "likes" : 0,
                            "postID" : key] as [String : Any]
                let postFeed = ["\(key)" : feed]
                database.child("Posts").updateChildValues(postFeed)
            })
            
            uploadTask.resume()
        }
        
        //Bild i full storlek (denna uploadTask läggs sist eftersom denna blir färdig sist)
        if let imageData = UIImagePNGRepresentation(image!) {
            let uploadTask = imageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                let firstURL = metadata?.downloadURL()?.absoluteString
                
                let feed = ["pathToImage" : firstURL!] as [String : Any]
                database.child("Posts").child("\(key)").updateChildValues(feed)
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
