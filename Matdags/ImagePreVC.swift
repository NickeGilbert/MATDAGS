//  CameraImgPreVC.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-10-10.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import AVFoundation
import Firebase

class ImagePreVC: UIViewController {
    
    var s_image = [Images]()
    
    @IBOutlet weak var photo: UIImageView!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(String(describing: Auth.auth().currentUser?.uid))")
        
        photo.image = self.image
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
        let storage = Storage.storage().reference()
        
        let key = database.child("Posts").childByAutoId().key
        let imageRef = storage.child("images").child(uid!).child("\(key).jpg")
        
        if let imageData = UIImageJPEGRepresentation(image!, 0.6){
            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image/jpeg"
            
            let uploadTask = imageRef.putData(imageData, metadata: uploadMetadata) { (metadata, error) in
                if error != nil{
                    print("Det blev lite fel \(String(describing: error?.localizedDescription))")
                    return
                }
                    print("Det gick bra.. den här gången. \(String(describing: metadata))")
                    print("URL till bilden är \(String(describing: metadata?.downloadURL()))")
                
                    imageRef.downloadURL(completion: { (url, error) in
                    if let url = url {
                        let feed = ["userID" : uid,
                                    "pathToImage" : url.absoluteString,
                                    "likes" : 0,
                                    "author" : Auth.auth().currentUser?.displayName,
                                    "postID" : key] as [String: Any]
                        
                        let postFeed = ["\(key)" : feed]
                        database.child("Posts").updateChildValues(postFeed)
                    }
                })
            }
            
            uploadTask.resume()
            
        } else {
            print("Bilden kunde inte konverteras!")
        }
    }
}
