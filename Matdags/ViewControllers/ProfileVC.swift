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
        resizeImage()
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        getUserInfo()
        posts.removeAll()
        getPostInfo { (true) in
            self.profileCollectionFeed.reloadData()
        }
        //Nedan är för att hämta antal följare och antal man följer
        //Tror dock det behövs jobbas på finns i AppDelegate
        //AppDelegate.instance().countFollow()
        
        
        if(fromSearch == true) {
            // Du kommer från sökskärmen
            profileNameLabel.text = user.alias

        } else {
            if(FBSDKAccessToken.current() != nil) {
                profileSettingsButtonOutlet.isHidden = true;
                profileNameLabel.text = ""
                
                if FBSDKAccessToken.current() != nil {
                    fetchProfile()
                }
                
                let url = URL(string: "http://graph.facebook.com/"+FBSDKAccessToken.current().userID+"/picture?type=large")
                let task = URLSession.shared.dataTask(with: url!) { (data, response, error ) in
                    if error != nil {
                        print(error!)
                        return
                    } else {
                        var documentsDirectory:String?
                        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory , .userDomainMask, true)
                        
                        if paths.count > 0 {
                            documentsDirectory = paths[0]
                            let savePath = documentsDirectory! + "/.jpg"
                            FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
                            DispatchQueue.main.async {
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
                    let value = snapshot.value as! NSDictionary
                    let username = value["alias"] as? String ?? ""
                    self.profileNameLabel.text = username
                }) { (error) in
                    print(error.localizedDescription)
                }
                
                if(FBSDKAccessToken.current() == nil) {
                    profileNameLabel.text = user.alias
                }
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    func getPostInfo(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        let uid = Auth.auth().currentUser!.uid
        let db = Database.database().reference(withPath: "Users/\(uid)/Posts")
        db.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                for (_, post) in dictionary {
                    let appendPosts = Post()
                    appendPosts.pathToImage256 = post["pathToImage256"] as? String
                    appendPosts.postID = post["postID"] as? String
                    self.posts.insert(appendPosts, at: 0)
                    completionHandler(true)
                }
            }
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
            UploadImageToFirebase(in: dispatchGroup)
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
                    self.dismiss(animated: false, completion: nil)
                })
            })
            uploadTask.resume()
        }
    }
    
    func getUserInfo() {
        let uid = Auth.auth().currentUser!.uid
        let dbref = Database.database().reference(withPath: "Users/\(uid)")
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let tempSnapshot = snapshot.value as? [String : Any] {
                let appendInfo = User()
                appendInfo.profileImageURL = tempSnapshot["profileImageURL"] as? String
                self.profilePictureOutlet.downloadImage(from: appendInfo.profileImageURL )
            }
        })
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
        print("SWIPE SWIPE!!")
        tabBarController?.selectedIndex = 1
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        print("SWIPE SWIPE!!")
        tabBarController?.selectedIndex = 3
    }
}

