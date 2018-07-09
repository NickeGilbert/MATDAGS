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
import FirebaseDatabase

class ProfileVC: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet var profileCollectionFeed: UICollectionView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    @IBOutlet weak var profileSettingsButtonOutlet: UIButton!
    
    @IBOutlet weak var bendView: UIView!
    @IBOutlet weak var zeroImagesTextLabel: UILabel!
    
    
    
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var following: UILabel!
    
    @IBOutlet weak var settingsViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsViewInner: UIView!
    
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentsTextView: UITextView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ProfileCollectionFeedTopConstraint: NSLayoutConstraint!
    
    
    var yourPostsId = [String]()
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
    var seguePostID : String!
    
    //Database
    let db = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    let authedUser = Auth.auth().currentUser
    let storage = Storage.storage().reference()

    override func viewDidLoad() {
        
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        resizeImage()
        getUserInfo()
        
        profileNameLabel.text = ""
        profileSettingsButtonOutlet.isHidden = false
        getFollwersCounting()
        
        zeroImagesTextLabel.text = NSLocalizedString("zeroImagesTextLabel", comment: "<#T##String#>")
        followingLabel.text = NSLocalizedString("followingLabel", comment: "")
        followersLabel.text = NSLocalizedString("followerLabel", comment: "")
        
        bendView.layer.cornerRadius = 10
        bendView.clipsToBounds = true
        
        settingsViewTopConstraint.constant = view.bounds.size.height
        settingsViewInner.layer.cornerRadius = 10
        settingsViewInner.clipsToBounds = true
        commentsViewTopConstraint.constant = view.frame.height
        commentsTextView.contentInset = UIEdgeInsetsMake(40, 5, 5, 5)
        
    }
    
    func fixDescriptionLabel() {
        if descriptionLabel.text != "" {
            descriptionLabelHeightConstraint.constant = 50
        }else{
            descriptionLabelHeightConstraint.constant = 1
        }
        ProfileCollectionFeedTopConstraint.constant = 20
    }

    
    override func viewDidAppear(_ animated: Bool) {
        if posts.isEmpty {
            loadData()
        }

        fixDescriptionLabel()
//        descriptionLabel.sizeToFit()
//        print(descriptionLabel.frame.height) // använd när animering ska göras, behövs nog inte pga collectionview constanten uppdateras också vid byte av text.
        
        
        
    }
    
    @IBAction func profileDescriptionAction(_ sender: Any) {

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                self.commentsViewTopConstraint.constant = 0
            })
        }

        addToolbar()
        commentsTextView.text = ""
        commentsTextView.becomeFirstResponder()
    }
    
    
    func addToolbar() {
        
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.ImagePageVCClose)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(self.ImagePageVCDoneEditing)),]
        
        numberToolbar.sizeToFit()
        commentsTextView.inputAccessoryView = numberToolbar
    }
    
    @objc func ImagePageVCClose() {
        commentsTextView.text = ""
        self.view.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                self.commentsViewTopConstraint.constant = self.view.frame.height
            })
        }
    }
    
    @objc func ImagePageVCDoneEditing() {
            UploadProfileDescription(in: dispatchGroup, text: commentsTextView.text)
            self.commentsTextView.resignFirstResponder()
            self.view.endEditing(true)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                    self.commentsViewTopConstraint.constant = self.view.frame.height
                })
            }
    }
    
    
    @IBAction func openSettingsAction(_ sender: Any) {
        tabBarController?.tabBar.isHidden = true
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
            self.settingsViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
        
    }
    
    @IBAction func closeSettingsAction(_ sender: Any) {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
            self.settingsViewTopConstraint.constant = self.view.bounds.size.height
            self.tabBarController?.tabBar.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    
    @IBAction func changeProfilePictureAction(_ sender: Any) {
        changeProfilePicture()
    }
    
    
    @IBAction func deleteAccountAction(_ sender: Any) {
        deleteAccount()
    }
    
    
    @objc func loadData() {
        getPostInfo{ (true) in
            self.posts.sort(by: {$0.date > $1.date})
            self.getFollwersCounting()
            self.profileCollectionFeed.reloadData()
        }
    }
    
    func getFollwersCounting() {
        db.child("Users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            let uAreFollowing = value["followingCounter"]
            if uAreFollowing != nil {
            }
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
        let prefs = UserDefaults.standard
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let tempSnapshot = snapshot.value as? [String : Any] {
                let appendInfo = User()
                appendInfo.profileImageURL = tempSnapshot["profileImageURL"] as? String
                if appendInfo.profileImageURL != "" {
                    prefs.set(appendInfo.profileImageURL!, forKey: "userProfilePhoto")
                    self.profilePictureOutlet.downloadImage(from: appendInfo.profileImageURL )
                } else {
                    return
                }
                appendInfo.userDescription = "\(tempSnapshot["userDescription"] as! String)"
                if appendInfo.userDescription != "" {
                    self.descriptionLabel.text = appendInfo.userDescription
                    self.fixDescriptionLabel()
                    print("AAAALLL GOOD?")
                }else{
                    print("Jepp det är tomt...")
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
        cell.layer.cornerRadius = 5
        
        if self.posts[indexPath.row].vegi == nil || self.posts[indexPath.row].vegi == false {
            cell.vegiIcon.isHidden = true
        }else{
            cell.vegiIcon.isHidden = false
        }
        
        if self.posts[indexPath.row].pathToImage256 != nil {
            cell.myProfileImageCollection.downloadImage(from: self.posts[indexPath.row].pathToImage256)
        } else {
            
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
        print("Fetching Facebook Profile...")
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
        if self.posts.count < 1 {
            profileCollectionFeed.isHidden = true
        }else{
            profileCollectionFeed.isHidden = false
        }
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width/3.2, height: self.view.frame.width/3.2)
        return size
    }
    
    func changeProfilePicture() {
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
        }else{
            print("\n Image not uploaded \n")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func UploadProfileDescription(in dispatchGroup: DispatchGroup, text : String){
        AppDelegate.instance().showActivityIndicator()
        let uid = Auth.auth().currentUser?.uid
        let database = Database.database().reference(withPath: "Users/\(uid!)")
        database.child("userDescription").setValue(text)
        AppDelegate.instance().dismissActivityIndicator()
        descriptionLabel.text = text
        fixDescriptionLabel()
    }

    func UploadImageToFirebase(in dispatchGroup: DispatchGroup) {
        
        AppDelegate.instance().showActivityIndicator()
        let uid = Auth.auth().currentUser?.uid
        let prefs = UserDefaults.standard
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
                    prefs.set(imageURL!, forKey: "userProfilePhoto")
                    let postURL = ["profileImageURL" : imageURL!] as [String : Any]
                    database.updateChildValues(postURL)
                } else {
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                }
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main, execute: {
                    print("\n Async completed \n")
                    AppDelegate.instance().dismissActivityIndicator()
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
    
    func deleteAccount() {
        let alert = UIAlertController(title: NSLocalizedString("DeleteAccountHeader", comment: ""), message: NSLocalizedString("DeleteAccountText", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("deleteAccountYES", comment: ""), style: .destructive, handler: { action in
            self.deleteUser()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("deleteAccountNO", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
 
    func fetchMyPosts(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        print("Fetching user Posts...")
        yourPostsId.removeAll()
        let dbref = db.child("Users/\(uid!)/Posts")
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                for (_, post) in dict {
                    let appendInfo = User()
                    appendInfo.postID = post["postID"] as? String ?? ""
                    self.yourPostsId.append(appendInfo.postID)
                }
                completionHandler(true)
            }
        })
    }
    
    func deleteData(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        for id in yourPostsId {
            db.child("Posts/\(id)").removeValue { (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
            }
            storage.child("images/\(uid!)/\(id)").delete { (error) in
                if error != nil {
                    print(error!)
                    return
                }
            }
            storage.child("images/\(uid!)/\(id)256").delete { (error) in
                if error != nil {
                    print(error!)
                    return
                }
            }
        }
        print("User Posts successfully deleted!")
        print("User Images successfully deleted!")
        completionHandler(true)
    }
}

