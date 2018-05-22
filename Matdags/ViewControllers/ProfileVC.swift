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
    
    @IBOutlet var profileCollectionFeed: UICollectionView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    @IBOutlet weak var profileSettingsButtonOutlet: UIButton!
    
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var following: UILabel!
    
    
    var ref: DatabaseReference!
    var FBdata : Any?
    var titleName = ""
    let imagePicker = UIImagePickerController()
    var newPic = UIImage()
    var posts = [Post]()
    var image: UIImage!
    let dispatchGroup = DispatchGroup()
    var user = User()
    var users = [User]()
    var fromSearch = false

    override func viewDidLoad() {
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
//        if posts.isEmpty {
//            loadData()
//        }
        
        resizeImage()
        getUserInfo()
        
        profileNameLabel.text = ""
        profileSettingsButtonOutlet.isHidden = false
        
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        ref.child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            let username = value["alias"] as? String ?? ""
            
            let followingCounter = value["followingCounter"] as? Int ?? 0
            let followerCounter = value["followerCounter"] as? Int ?? 0
            
            self.following.text = String(followingCounter)
            self.followers.text = String(followerCounter)
            self.profileNameLabel.text = username
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        posts.removeAll()
        loadData()
    }
    
    @objc func loadData() {
        getPostInfo{ (true) in
            self.posts.sort(by: {$0.date > $1.date})
            self.profileCollectionFeed.reloadData()
            print(self.posts.count)
        }
    }
    
    func getPostInfo(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        posts.removeAll()
        let uid = Auth.auth().currentUser!.uid
        let db = Database.database().reference(withPath: "Users/\(uid)/Posts")
        db.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                for (_, post) in dictionary {
                    let appendPosts = Post()
                    appendPosts.date = post["date"] as? String
                    appendPosts.pathToImage256 = post["pathToImage256"] as? String
                    appendPosts.postID = post["postID"] as? String
                    appendPosts.vegi = post["vegetarian"] as? Bool
                    self.posts.append(appendPosts)
                }
            }
            completionHandler(true)
        })
    }
    
    func getUserInfo() {
        let uid = Auth.auth().currentUser!.uid
        let dbref = Database.database().reference(withPath: "Users/\(uid)")
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let tempSnapshot = snapshot.value as? [String : Any] {
                let appendInfo = User()
                appendInfo.profileImageURL = tempSnapshot["profileImageURL"] as? String
                if appendInfo.profileImageURL != ""  {
                    self.profilePictureOutlet.downloadImage(from: appendInfo.profileImageURL )
                } else {
                    print("\n profileImageURL not found \n")
                    return
                }
            }
        })
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! ProfileCell
        
       let cachedImages = cell.viewWithTag(1) as? UIImageView
        cell.myProfileImageCollection.image = nil
        cell.vegiIcon.isHidden = true
        cell.layer.cornerRadius = 2
        
        if self.posts[indexPath.row].vegi == nil || self.posts[indexPath.row].vegi == false {
            cell.vegiIcon.isHidden = true
        }else{
            cell.vegiIcon.isHidden = false
        }
        
        if self.posts[indexPath.row].pathToImage256 != nil {
            cell.myProfileImageCollection.downloadImage(from: self.posts[indexPath.row].pathToImage256)
        } else {
            print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
        }
        
        cachedImages?.sd_setImage(with: URL(string: self.posts[indexPath.row].pathToImage256))
        
        return cell
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
            request!.start { (connection, result, error) in
                if error != nil {
                    print("\n",error!,"\n")
                } else {
                    let fbRes = result as! NSDictionary
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
    
    @IBAction func profileImageAction(_ sender: UIButton) {
        print(newPic)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.modalPresentationStyle = .overCurrentContext
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
//    @IBAction func profileSettingsAction(_ sender: UIButton) {
//        print(newPic)
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            imagePicker.delegate = self
//            imagePicker.modalPresentationStyle = .overCurrentContext
//            imagePicker.sourceType = .photoLibrary;
//            imagePicker.allowsEditing = true
//            self.present(imagePicker, animated: true, completion: nil)
//        }
//    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Running")
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePictureOutlet.contentMode = .scaleAspectFill
            profilePictureOutlet.image = pickedImage
            profilePictureOutlet.layoutIfNeeded()
            newPic = pickedImage
            UploadImageToFirebase(in: dispatchGroup)
        }else{
            print("\n Image not uploaded \n")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func UploadImageToFirebase(in dispatchGroup: DispatchGroup) {
        AppDelegate.instance().showActivityIndicator()
        let uid = Auth.auth().currentUser?.uid
        let database = Database.database().reference(withPath: "Users/\(uid!)")
        let storage = Storage.storage().reference().child("profileimages").child(uid!)
        let key = database.childByAutoId().key
        let imageRef = storage.child("\(key)")
        let resizedImage = AppDelegate.instance().resizeImage(image: self.newPic, targetSize: CGSize.init(width: 256, height: 256))
        
        //Ladda upp profilbild
        if let imageData = UIImageJPEGRepresentation(resizedImage, 0.8) {
            dispatchGroup.enter()
            let uploadTask = imageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                    print(error!)
                    return
                }
                let imageURL = metadata?.downloadURL()?.absoluteString
                if imageURL != nil {
                    let postURL = ["profileImageURL" : imageURL!] as [String : Any]
                    database.updateChildValues(postURL)
                    print("\n Profile picture uploaded successfully! \n")
                } else {
                    print("\n Could not allocate URL for resized image. \n")
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                }
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main, execute: {
                    print("\n Async completed \n")
                    AppDelegate.instance().dismissActivityIndicator()
//                    self.dismiss(animated: false, completion: nil)
                })
            })
            uploadTask.resume()
        }
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "imagePageSegProfile", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "imagePageSegProfile")
        {
            let selectedCell = sender as! NSIndexPath
            let selectedRow = selectedCell.row
            let imagePage = segue.destination as! ImagePageVC
            imagePage.seguePostID = self.posts[selectedRow].postID
        } else {
            print("\n Segue with identifier (imagePage) not found. \n")
        }
    }
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        tabBarController?.selectedIndex = 1
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        tabBarController?.selectedIndex = 3
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        URLCache.shared.removeAllCachedResponses()
    }
    
    @IBAction func deleteaccountBtn(_ sender: Any) {
      
        self.deleteAccountAlert(title: deleteTitle, message: deleteText)
        
        //Resten av funktion ligger i Extensions/CreateAlertExt.swift
        
    }
}

