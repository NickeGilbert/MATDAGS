//  ImagePageVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-11-05.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase

class ImagePageVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var vegiIcon: UIImageView!
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var starButtons: [UIButton]!
    @IBOutlet weak var followerButton: UIButton!
    @IBOutlet weak var unfollowingButton: UIButton!
    @IBOutlet weak var toSubViewButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var subviewUnfollowButton: UIButton!
    
    @IBOutlet weak var imagePageSettingsView: UIView!
    @IBOutlet weak var deleteImage: UIButton!
    
    @IBOutlet weak var imagePageSettingsViewHeightConstraint: NSLayoutConstraint!
    
    //test daniel
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var tableViewConstraintH: NSLayoutConstraint!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsTextField: UITextField!
    
    
    @IBOutlet weak var topSubView: UIView!
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var subviewUsername: UILabel!
    @IBOutlet weak var subviewProfileImage: UIImageView!
    @IBOutlet weak var subviewCollectionFeed: UICollectionView!
    @IBOutlet weak var subviewFollowButton: UIButton!
    
    
    let dispatchGroup = DispatchGroup()
    let uid = Auth.auth().currentUser!.uid
    let db = Database.database()
    let alias = Auth.auth().currentUser!.displayName
    
    var seguePostID : String!
    var users = [User]()
    var count : Int = 0
    var countFollower = 0
    var posts = [Post]()
    var subviews = [Subview]()
    var userFollowing = [String]()
    
    var commentsRef = Database.database().reference()
    var comments: Array<DataSnapshot> = []
    
    //Rating System
    var starsHighlighted = 0.0
    var fetchedStars = 0.0
    var usersRated = 0.0
    var postRating = 0.0
    
    var commentConter: Int = 0
    
    //test daniel
    var commentsCell = [CommentsCell]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followerButton.isHidden = true
        unfollowingButton.isHidden = true
        subviewFollowButton.isHidden = true
        subviewUnfollowButton.isHidden = true
        vegiIcon.isHidden = true
        topSubView.isHidden = true
        subview.isHidden = false
        commentsTextField.delegate = self
        imagePageSettingsView.isHidden = true
        deleteImage.setTitle(removeImage,for: .normal)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        comments.removeAll()
        commentsRef = commentsRef.child("Posts/\(seguePostID!)/comments")
        
        downloadInfo { (true) in
            print(self.posts[0].userID)
            if self.posts[0].userID != self.uid {
                self.deleteImage.isHidden = true
                self.imagePageSettingsViewHeightConstraint.constant = 60
                self.followerButton.isHidden = false
                self.subviewFollowButton.isHidden = false
            } else {
                self.deleteImage.isHidden = false
                self.followerButton.isHidden = true
                self.unfollowingButton.isHidden = true
                self.subviewFollowButton.isHidden = true
            }
            if self.posts[0].usersRated != nil {
                self.usersRated = self.posts[0].usersRated
            } else {
                self.usersRated = 0
            }
            self.postRating = self.posts[0].rating
            self.sortFirebaseInfo()
            self.getStars()
            self.getUserFollowing()
        }
        
        observeComments()
        
        commentsTableView.isScrollEnabled = false
        commentsTableView.separatorStyle = .none
        subview.layer.cornerRadius = 20
        subview.clipsToBounds = true
        followerButton.layer.cornerRadius = 5
        followerButton.clipsToBounds = true
        unfollowingButton.layer.cornerRadius = 5
        unfollowingButton.clipsToBounds = true
        subviewFollowButton.layer.cornerRadius = 5
        subviewFollowButton.clipsToBounds = true
        subviewUnfollowButton.layer.cornerRadius = 5
        subviewUnfollowButton.clipsToBounds = true
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        //myImageView.dropShadow()
        imagePageSettingsView.layer.cornerRadius = 5
    }
    
    
    
    func customWillDisappear(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        getInfoForIncremation { (true) in
            if self.posts[0].usersRated == nil || self.posts[0].usersRated == 0 {
                self.usersRated = 0
            } else {
                self.usersRated = self.posts[0].usersRated
            }
            if self.posts[0].rating == nil || self.posts[0].rating == 0 {
                self.postRating = 0
            } else {
                self.postRating = self.posts[0].rating
            }
            self.postStars { (true) in
                completionHandler(true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentsCell
        
        let cellHeight = cell.frame.height
        let tableHeight = tableView.frame.height
        
        self.tableViewConstraintH.constant = tableHeight + cellHeight
        
        if let commentDict = comments[indexPath.row].value as? [String : AnyObject] {
            cell.commentsTextLabel.text = commentDict["comment"] as? String
            cell.commentsNameLabel.text  = commentDict["alias"] as? String
        }
        return cell
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func observeComments() {
        commentsRef.observe(.childAdded, with: { (snapshot) -> Void in
            self.comments.append(snapshot)
            self.commentsTableView.beginUpdates()
            self.commentsTableView.insertRows(at: [IndexPath(row: self.comments.count-1, section: 0)], with: UITableViewRowAnimation.automatic)
            self.commentsTableView.endUpdates()
        })
        commentsRef.observe(.childRemoved, with: { (snapshot) -> Void in
            let index = self.indexOfMessage(snapshot)
            self.comments.remove(at: index)
            self.commentsTableView.beginUpdates()
            self.commentsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
            self.commentsTableView.endUpdates()
        })
    }
    
    func indexOfMessage(_ snapshot: DataSnapshot) -> Int {
        var index = 0
        for  comment in self.comments {
            if snapshot.key == comment.key {
                return index
            }
            index += 1
        }
        return -1
    }
    
    func getInfoForIncremation(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        let getInfo = Post()
        let dbref = db.reference(withPath: "Posts/\(self.posts[0].postID)")
        dbref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                getInfo.rating = dict["rating"] as? Double
                getInfo.usersRated = dict["usersRated"] as? Double
        
            }
            print("\ngetInfoForIncremation true")
            completionHandler(true)
        }
    }
    
    func downloadInfo(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        let dbref = Database.database().reference().child("Posts").child("\(seguePostID!)")
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let getInfo = Post()
                getInfo.pathToImage = dictionary["pathToImage"] as! String
                getInfo.rating = dictionary["rating"] as! Double
                getInfo.userID = dictionary["userID"] as! String
                getInfo.postID = dictionary["postID"] as! String
                getInfo.alias = dictionary["alias"] as! String
                getInfo.imgdescription = dictionary["imgdescription"] as! String
                getInfo.vegi = dictionary["vegetarian"] as? Bool
                getInfo.usersRated = dictionary["usersRated"] as? Double
                self.posts.append(getInfo)
                print("\n \(self.posts[0].userID) \n")
                completionHandler(true)
            } else {
                print("\n No info in dictionary \n")
            }
        })
    }
    
    @IBAction func followUser(_ sender: Any) {
        followerButton.isHidden = true
        unfollowingButton.isHidden = false
        getFollower()
        addFollower()
    }
    
    @IBAction func commentButtonClick(_ sender: UIButton) {
        imagePageSettingsView.isHidden = true
        commentsTextField.text = ""
        commentsView.isHidden = false
        commentsTextField.becomeFirstResponder()
    }
    
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if commentsTextField.text != "" {
            let postID = self.posts[0].postID
            let postRef = db.reference(withPath: "Posts/\(postID!)/comments")
            let key = postRef.childByAutoId().key
            let commentSend = commentsTextField.text
            
            print("Post refferens : \(postRef)")
            print("Mitt UID: \(uid)")
            print("Kommentaren : \(commentSend!)")
            print("User alias : \(alias!)")
        
            postRef.child(key).updateChildValues(["uid" : uid] as [String: Any])
            postRef.child(key).updateChildValues(["alias" : alias!] as [String : Any])
            postRef.child(key).updateChildValues(["comment" : commentSend!] as [String : Any])
            
            self.commentsTextField.resignFirstResponder()
            self.view.endEditing(true)
            self.commentsView.isHidden = true
            return true
            
        }else{
            commentsTextField.resignFirstResponder()
            self.view.endEditing(true)
            commentsView.isHidden = true
            return true
        }
    }
    
    func sortFirebaseInfo() {
        if self.posts[0].pathToImage != nil {
            myImageView.downloadImage(from: self.posts[0].pathToImage)
        } else {
            print("\n No Image URL found in array. \n")
        }

        if posts[0].alias != nil{
            toSubViewButton.setTitle(self.posts[0].alias, for: .normal)
        } else {
            toSubViewButton.setTitle(self.posts[0].userID, for: .normal)
        }
        if self.posts[0].imgdescription != nil {
            descriptionLabel.text = self.posts[0].imgdescription
        } else {
            descriptionLabel.text = "Ingen beskrivning."
        }
        
        if self.posts[0].vegi == nil || self.posts[0].vegi == false {
            vegiIcon.isHidden = true
        } else {
            vegiIcon.isHidden = false
        }
    }
    
    @IBAction func imagePageBack(_ sender: Any) {
        customWillDisappear { (true) in
            self.posts.removeAll()
            self.subviews.removeAll()
            self.commentsRef.removeAllObservers()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
  
    @IBAction func clickedOnUsername(_ sender: Any) {
        getUserProfileImage { (true) in
            self.downloadImages(completionHandler: { (true) in
                self.imagePageSettingsView.isHidden = true
                self.topSubView.isHidden = false
                self.subviewUsername.text = self.posts[0].alias
            })
        }
    }
    
    @IBAction func openContainerView(_ sender: Any) {
        if self.imagePageSettingsView.isHidden == true {
             self.imagePageSettingsView.isHidden = false
        }   else {
             self.imagePageSettingsView.isHidden = true
        }
    }

    @IBAction func reportImage(_ sender: Any) {
        let alert = UIAlertController(title: "Vill du Anmäla bilden?", message: "Tänk på att inte missbruka denna tjäst då du själv kan bli avstängd", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Anmäl", style: .destructive, handler: { action in
            
            
            let alert2 = UIAlertController(title: "Anmälan är skickad", message: "Vi ska ta en titt på bilden", preferredStyle: .alert)
            alert2.addAction(UIAlertAction(title: "Stäng", style: .cancel, handler: nil))
            self.present(alert2, animated: true)
            
            
        }))
        alert.addAction(UIAlertAction(title: "Stäng", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    @IBAction func deleteImage(_ sender: Any) {
        let alert = UIAlertController(title: "Vill du ta bort bilden?", message: "Detta går inte att ångra", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ta bort", style: .destructive, handler: { action in
            self.deletePosts()
        }))
        alert.addAction(UIAlertAction(title: "Stäng", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    func deletePosts() {

        //Tas bort från ImagePageVC
        let ref = Database.database().reference().child("Posts").child(seguePostID)
            ref.removeValue { (error, ref) in
            if error != nil {
                print("DIDN'T GO THROUGH")
                return
            }
            self.dismiss(animated: true, completion: nil)
            print("POST DELETED")
        }
        
        //Tas bort från ProfileVC
        let myRef = Database.database().reference().child("Users").child(uid).child("Posts").child(seguePostID)
        myRef.removeValue { (error, ref) in
            if error != nil {
                print("DIDN'T GO THROUGH")
                return
            }
            print("POST DELETED")
        }
    }
    
    func getUserFollowing() {
        //Används för Subviewn
        var ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        ref.child("Users").child(userID!).child("Following").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if (snapshot.value as? NSDictionary) != nil { //FUNGERER INTE ÄN
                let value = snapshot.value as! NSDictionary
                for uidValue in value {
                    print("SNAPSHOT", uidValue.value)
                    let appendUser = User()
                    appendUser.uid = uidValue.value as? String
                    self.userFollowing.append(appendUser.uid)
                    
                    self.checkUserUid()
                }
            } else {
                return
            }
        })
    }
    
    func checkUserUid() {
        
       let userId = self.posts[0].userID!
        
        if uid == userId {
            self.subviewFollowButton.isHidden = true
            self.subviewUnfollowButton.isHidden = true
            print("MY USERID IS: ", self.posts[0].userID!)
            print("userId is: ", userId)
        } else {
            print("WHAT USER IS THIS? :", userId)
            print("YOUR ARE FOLLOWING :", self.userFollowing)
            for user in userFollowing {
                print("\nUSER IS: ", user)
                print("YOUR ARE FOLLOWING: ", userFollowing)
                
                if userId == user {
                    print("SUCCESS CHECK:", user, userFollowing)
                    print("\nYou are following this user.")
                    self.followerButton.isHidden = true
                    self.unfollowingButton.isHidden = false
                    self.subviewFollowButton.isHidden = true
                    self.subviewUnfollowButton.isHidden = false
                    break
                } else {
                    print("FAILED CHECK:", user, userFollowing)
                    print("\nYou are not following this user.")
                    self.followerButton.isHidden = false
                    self.unfollowingButton.isHidden = true
                    self.subviewFollowButton.isHidden = false
                    self.subviewUnfollowButton.isHidden = true
                }
            }
            print("after user loop")
        }
        
        
    }
    
}


















