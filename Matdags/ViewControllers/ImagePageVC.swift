//  ImagePageVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-11-05.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase

class ImagePageVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var vegiIcon: UIImageView!
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var starButtons: [UIButton]!
    @IBOutlet weak var followerButton: UIButton!
    @IBOutlet weak var toSubViewButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!

    //test daniel
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var tableViewConstraintH: NSLayoutConstraint!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsTextField: UITextField!
    
    
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
        vegiIcon.isHidden = true
        subview.isHidden = true
        commentsTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        comments.removeAll()
        commentsRef = commentsRef.child("Posts/\(seguePostID!)/comments")
        
        downloadInfo { (true) in
            print(self.posts[0].userID)
            if self.posts[0].userID != self.uid {
                self.followerButton.isHidden = false
            } else {
                self.followerButton.isHidden = true
            }
            if self.posts[0].usersRated != nil {
                self.usersRated = self.posts[0].usersRated
            } else {
                self.usersRated = 0
            }
            self.postRating = self.posts[0].rating
            self.sortFirebaseInfo()
            self.getStars()
        }
        
        observeComments()
        
        commentsTableView.isScrollEnabled = false
        commentsTableView.separatorStyle = .none
        subview.layer.cornerRadius = 3
        subview.clipsToBounds = true
        followerButton.layer.cornerRadius = 3
        followerButton.clipsToBounds = true
        subviewFollowButton.layer.cornerRadius = 3
        subviewFollowButton.clipsToBounds = true
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
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
    
    func postStars(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        if self.posts[0].postID != nil {
            //Post stars to userdb
            let uref = db.reference(withPath: "Users/\(uid)/RatedPosts/\(self.posts[0].postID!)")
            if starsHighlighted != 0 {
                let ratedPosts = ["Stars" : starsHighlighted] as [String : Any]
                uref.updateChildValues(ratedPosts)
            }
            
            //Post stars to postdb
            let dbref = db.reference(withPath: "Posts/\(self.posts[0].postID!)")
            let a = fetchedStars - (fetchedStars - starsHighlighted)
            let b = fetchedStars + (starsHighlighted - fetchedStars)
            if starsHighlighted < fetchedStars {
                let postStars = ["rating" : postRating - fetchedStars + a] as [String : Double]
                dbref.updateChildValues(postStars)
            } else if starsHighlighted > fetchedStars {
                let postStars = ["rating" : postRating - fetchedStars + b] as [String : Double]
                dbref.updateChildValues(postStars)
            }
            
            if fetchedStars == 0 && starsHighlighted != 0 {
                usersRated+=1
                dbref.updateChildValues(["usersRated" : usersRated] as [String : Double])
            }
            print("\npostStars true")
            completionHandler(true)
        } else {
            print("\nNo PostID found!")
            completionHandler(true)
        }
    }
    
    func getStars() {
        //Get number of stars
        let getInfo = User()
        let uref = Database.database().reference(withPath: "Users/\(uid)/RatedPosts/\(self.posts[0].postID!)")
        uref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let firstSnapshot = snapshot.value as? [String : Any] {
                getInfo.stars = firstSnapshot["Stars"] as? Int
                self.starsHighlighted = Double(getInfo.stars)
                self.fetchedStars = Double(getInfo.stars)
                for button in self.starButtons {
                    for i in 0...Int(self.starsHighlighted)-1 {
                        if button.tag <= i {
                            button.setImage(#imageLiteral(resourceName: "fullstar30"), for: .normal)
                        }
                    }
                }
            } else {
                print("\n Cant find rating for post. \n")
            }
        })
        
        
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
        getFollower()
        addFollower()
    }
    
    @IBAction func commentButtonClick(_ sender: UIButton) {
        commentsView.isHidden = false
        commentsTextField.becomeFirstResponder()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
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
    
    func addFollower() {
        let dbref = db.reference(withPath: "Users/\(uid)/Following")
        let uref = db.reference(withPath: "Users/\(uid)")
        if self.posts[0].userID != nil {
            let following = ["\(self.posts[0].alias!)" : self.posts[0].userID!] as [String : Any]
            
            count+=1
            let counter = ["followingCounter" : count ] as [String : Int]
            uref.updateChildValues(counter)
            dbref.updateChildValues(following)
        } else {
            print("\n userID not found when adding follower \n")
        }
    }
    
    func getFollower() {
        let followerid = posts[0].userID
        let dbref = db.reference(withPath: "Users/\(followerid!)/Follower")
        let uref = db.reference(withPath: "Users/\(uid)")
        if self.posts[0].userID != nil {
            let follower = ["\(alias!)" : "\(uid)" ] as [String : Any]
            
            countFollower+=1
            let counter = ["followerCounter" : countFollower ] as [String : Int]
            uref.updateChildValues(counter)
            dbref.updateChildValues(follower)
        } else {
            print("\n userID not found when getting follower \n")
        }
    }
    
    func sortFirebaseInfo() {
        if self.posts[0].pathToImage != nil {
            myImageView.downloadImage(from: self.posts[0].pathToImage)
        } else {
            print("\n No Image URL found in array. \n")
        }
        if postRating != 0 || usersRated != 0 {
            ratingLabel.text = "\(Double(postRating / usersRated)) Rating"
        } else {
            ratingLabel.text = "No Rating"
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
    
    @IBAction func starButtonsTapped(_ sender: UIButton) {
        starsHighlighted = Double(sender.tag + 1)
        print(starsHighlighted)
        
        for button in starButtons {
            button.setImage(#imageLiteral(resourceName: "emptystar30"), for: .normal)
            
            if Double(button.tag) <= starsHighlighted-1 {
                button.setImage(#imageLiteral(resourceName: "fullstar30"), for: .normal)
            }
        }
    }
    
        ///////////////////////////////////SUBVIEW//////////////////////////////////////////////
    
    @IBAction func clickedOnUsername(_ sender: Any) {
        getUserProfileImage { (true) in
            self.downloadImages(completionHandler: { (true) in
                self.subview.isHidden = false
                self.subviewFollowButton.isHidden = false
                self.subviewUsername.text = self.posts[0].alias
            })
        }
    }
    
    @IBAction func subviewFollowBtn(_ sender: Any) {
        getFollower()
        addFollower()
    }
    
    func getUserProfileImage(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        if subviews.count == 0 {
            let getInfo = User()
            let puid = self.posts[0].userID!
            let dbref = Database.database().reference(withPath: "Users/\(puid)")
            dbref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let firstSnapshot = snapshot.value as? [String : Any] {
                    getInfo.profileImageURL = firstSnapshot["profileImageURL"] as? String
                    if getInfo.profileImageURL != ""  {
                        self.subviewProfileImage.downloadImage(from: getInfo.profileImageURL)
                        completionHandler(true)
                        print("\nHämtade profilbild")
                    } else {
                        completionHandler(true)
                        print("\n profileImageURL not found \n")
                        return
                    }
                } else {
                    print("\nCouldnt fetch profile image for subview.")
                    completionHandler(true)
                }
            })
        } else {
            completionHandler(true)
        }
    }

    func downloadImages(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        if subviews.count == 0 {
            subviews.removeAll()
            let puid = self.posts[0].userID!
            let dbref = Database.database().reference(withPath: "Users/\(puid)/Posts")
            dbref.queryOrderedByKey().queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    for (_, post) in dictionary {
                        let appendPost = Subview()
                        appendPost.pathToImage256 = post["pathToImage256"] as? String
                        appendPost.postID = post["postID"] as? String
                        appendPost.vegi = post["vegetarian"] as? Bool
                        self.subviews.append(appendPost)
                        completionHandler(true)
                    }
                } else {
                    completionHandler(true)
                    print("\nCouldnt download data for subview.")
                }
                self.subviewCollectionFeed.reloadData()
            })
        } else {
            completionHandler(true)
        }
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePageSubviewCell", for: indexPath) as! ImagePageSubViewCell
        
        let cachedImages = cell.viewWithTag(1) as? UIImageView
        
        cell.mySubviewCollectionFeed.image = nil
        if self.subviews[indexPath.row].pathToImage256 != nil {
            cell.mySubviewCollectionFeed.downloadImage(from: self.subviews[indexPath.row].pathToImage256)
        } else {
            print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
        }
        
        cachedImages?.sd_setImage(with: URL(string: self.subviews[indexPath.row].pathToImage256))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let size = CGSize(width: view.frame.width/3.5, height: view.frame.width/3.5)
        return size
    }
    
    //INTE GJORT SEGUE ÄN!
   /* func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "imagePageSegSub", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "imagePageSegSub")
        {
            let selectedCell = sender as! NSIndexPath
            let selectedRow = selectedCell.row
            let imagePage = segue.destination as! ImagePageVC
            imagePage.seguePostID = self.posts[selectedRow].postID
        } else {
            print("\n Segue with identifier (imagePage) not found. \n")
        }
    }*/
    ///////////
    
    @IBAction func closeCommentButton(_ sender: UIButton) {
        commentsView.isHidden = true
        self.view.endEditing(true)
    }
    
    @IBAction func closeSubview(_ sender: Any) {
        subview.isHidden = true
    }
    
}
