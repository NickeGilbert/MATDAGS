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
    
    let dispatchGroup = DispatchGroup()
    
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
        UploadImageToFirebase(in: dispatchGroup)
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
    
    func UploadImageToFirebase(in dispatchGroup: DispatchGroup) {
        AppDelegate.instance().showActivityIndicator()
        let uid = Auth.auth().currentUser?.uid
        let database = Database.database().reference(withPath: "Posts")
        let usrdatabase = Database.database().reference(withPath: "Users")
        let storage = Storage.storage().reference().child("images").child(uid!)
        let key = database.childByAutoId().key
        let imageRef = storage.child("\(key)")
        let imageRef256 = storage.child("\(key)256")
        let resizedImage = resizeImage(image: self.image!, targetSize: CGSize.init(width: 256, height: 256))
        let fullImage = resizeImage(image: self.image!, targetSize: CGSize.init(width: 1024, height: 1024))
        
        //Datum
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        let result = formatter.string(from: date)
        
        let postfeed = ["userID" : uid!,
                    "date": result,
                    "rating" : 0,
                    "alias" : Auth.auth().currentUser!.displayName!,
                    "imgdescription" : self.addTextField.text!,
                    "postID" : key] as [String : Any]
        database.child("\(key)").updateChildValues(postfeed)
        usrdatabase.child("\(uid!)").child("Posts").updateChildValues(["\(key)" : key])
        
        //Bild i full storlek
        if let imageData = UIImageJPEGRepresentation(fullImage, 0.8) {
            dispatchGroup.enter()
            let uploadTask = imageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                    print(error!)
                    return
                }
                let firstURL = metadata?.downloadURL()?.absoluteString
                if firstURL != nil {
                    let postURL = ["pathToImage" : firstURL!]
                    database.child("\(key)").updateChildValues(postURL)
                    print("\n Image uploaded! \n")
                } else {
                    print("\n Could not allocate URL for full size image. \n")
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                }
                dispatchGroup.leave()
            })
            uploadTask.resume()
        }
        
        if let imageData256 = UIImageJPEGRepresentation(resizedImage, 0.8) {
            dispatchGroup.enter()
            let uploadTask256 = imageRef256.putData(imageData256, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                    print(error!)
                    return
                }
                let secondURL = metadata?.downloadURL()?.absoluteString
                if secondURL != nil {
                    let postURL = ["pathToImage256" : secondURL!] as [String : Any]
                    database.child("\(key)").updateChildValues(postURL)
                    print("\n Thumbnail uploaded! \n")
                } else {
                    print("\n Could not allocate URL for resized image. \n")
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                }
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main, execute: {
                    print("\n Async completed \n")
                    AppDelegate.instance().dismissActivityIndicator()
                    self.dismiss(animated: false, completion: nil)
                })
            })
            uploadTask256.resume()
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
