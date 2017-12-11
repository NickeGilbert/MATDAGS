//  ProfileVC.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-10-05.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
import AVFoundation

class ProfileVC: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var ref: DatabaseReference!
    
    @IBOutlet var profileCollectionFeed: UICollectionView!
//    @IBOutlet var profileImageCell: UICollectionViewCell!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    @IBOutlet weak var profileSettingsButtonOutlet: UIButton!
    
    var FBdata : Any?
    
    var titleName = ""
    let imagePicker = UIImagePickerController()
    var newPic = UIImage()
    var posts = [Post]()
    var image: UIImage!
    
    var users = User()
    var fromSearch = false

    override func viewDidLoad() {
        
        resizeImage()
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        
        if(fromSearch == true) {
            // Du kommer från sökskärmen
            profileNameLabel.text = users.alias

        } else {
            // Du ska se din egen profil
            
            if(FBSDKAccessToken.current() != nil) {
                
                profileSettingsButtonOutlet.isHidden = true;
                
                profileNameLabel.text = ""
                if let token = FBSDKAccessToken.current() {
                    fetchProfile()
                }
                
                let url = URL(string: "http://graph.facebook.com/"+FBSDKAccessToken.current().userID+"/picture?type=large")
                let task = URLSession.shared.dataTask(with: url!) { (data, response, error ) in
                    
                    if error != nil {
                        print("ERROR")
                    } else {
                        print("Checkpoint 1")
                        var documentsDirectory:String?
                        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory , .userDomainMask, true)
                        
                        if paths.count > 0 {
                            print("Checkpoint 2")
                            documentsDirectory = paths[0]
                            let savePath = documentsDirectory! + "/.jpg"
                            FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
                            
                            DispatchQueue.main.async {
                                print("Checkpoint 3")
                                print(savePath)
                                self.profilePictureOutlet.image = UIImage(named: savePath)
                            }
                        }
                    }
                }
                task.resume()
            } else {
                
                profileSettingsButtonOutlet.isHidden = false
                ref = Database.database().reference()
                
                let userID = Auth.auth().currentUser?.uid
                ref.child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as! NSDictionary
                    print(value)
                    
                    let username = value["alias"] as? String ?? ""

                    self.profileNameLabel.text = username
                    
                    // ...
                }) { (error) in
                    print(error.localizedDescription)
                }
                
                if(FBSDKAccessToken.current() == nil) {
                    profileNameLabel.text = users.alias
                }
            }
        }
        
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        posts.removeAll()
        downloadImages()

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! ProfileCell
        cell.myProfileImageCollection.image = nil
        if self.posts[indexPath.row].pathToImage256 != nil {
            cell.myProfileImageCollection.downloadImage(from: self.posts[indexPath.row].pathToImage256)
        } else {
            print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
        }
        return cell
    }
    
    func downloadImages() {
        let dbref = Database.database().reference(withPath: "Users").child((Auth.auth().currentUser?.uid)!).child("Posts")
        dbref.queryLimited(toFirst: 100).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                for (_, post) in dictionary {
                    let appendPost = Post()
                    appendPost.pathToImage256 = post["pathToImage256"] as? String
                    appendPost.postID = post["postID"] as? String
                    self.posts.insert(appendPost, at: 0)
                }
            }
            self.profileCollectionFeed.reloadData()
        })
    }
    
    func resizeImage(){
        profilePictureOutlet.layer.cornerRadius = profilePictureOutlet.frame.size.height / 2
        profilePictureOutlet.clipsToBounds = true
        self.profilePictureOutlet.layer.borderColor = UIColor.white.cgColor
        self.profilePictureOutlet.layer.borderWidth = 2
    }
    
    func fetchProfile() {

        let parameters = ["fields": "email, name, first_name, last_name, picture.type(large) "]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) -> Void in
            if error != nil {
                print("\n",error!,"\n")
                return
            }
            let request = FBSDKGraphRequest(graphPath:"me", parameters:parameters)
            
            request!.start {
                (connection, result, error) in
                if error != nil {
                    
                }else {
                    let fbRes = result as! NSDictionary
                    
                    print(fbRes)
                    self.profileNameLabel.text = fbRes.value(forKey: "name") as? String
                }
            }
        }
    }
    
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width/3.2, height: self.view.frame.width/3.2)
        return size
    }
    
    /*************************** nedan är kopia av kamera! ****************************/
    
    @IBAction func profileSettingsAction(_ sender: UIButton) {
        print(newPic)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.modalPresentationStyle = .overCurrentContext
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Running")
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePictureOutlet.contentMode = .scaleAspectFill
            profilePictureOutlet.image = pickedImage
            profilePictureOutlet.layoutIfNeeded()
            newPic = pickedImage
            print("YESS")
        }else{
            print("No fucking image")
        }
        print("NOOO")
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
        let resizedImage = resizeImage(image: self.newPic, targetSize: CGSize.init(width: 256, height: 256))
        let fullImage = resizeImage(image: self.newPic, targetSize: CGSize.init(width: 1024, height: 1024))
        //        var UserPostKey = Database.database().reference(withPath: "Posts") // NY TEST DANIEL
        
        //Datum
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "ddMMyyyy"
//        let result = formatter.string(from: date)
        
//        let postfeed = ["userID" : uid!,
//                        "date": result,
//                        "rating" : 0,
//                        "alias" : Auth.auth().currentUser!.displayName!,
//                        "imgdescription" : self.descriptionField.text!,
//                        "postID" : key] as [String : Any]
//
//        database.child("\(key)").updateChildValues(postfeed)
//        //        UserPostKey = usrdatabase.child("\(uid!)").child("Posts").child("\(key)")
//        usrdatabase.child("\(uid!)").child("Posts").updateChildValues(["\(key)" : key])
        
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
//                    database.child("\(key)").updateChildValues(postURL)
//                    usrdatabase.child("\(uid!)").child("Posts").child("\(key)").updateChildValues(postURL) // NY TEST DANIEL
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
//                    database.child("\(key)").updateChildValues(postURL)
//                    usrdatabase.child("\(uid!)").child("Posts").child("\(key)").updateChildValues(postURL) // NY TEST DANIEL
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

