//  ImagePageVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-11-05.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase

class ImagePageVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var vegiIcon: UIImageView!
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var pointsLabel: UILabel!
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
    
    
    @IBOutlet weak var subviewBackground: UIView!
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
    var starsHighlighted = 0
    var count : Int = 0
    var countFollower : Int = 0
    var posts = [Post]()
    
    var commentConter: Int = 0
    
    //test daniel
    var comments = [CommentsCell]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vegiIcon.isHidden = true
        subviewBackground.isHidden = true
        subview.isHidden = true
        commentsTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        downloadInfo { (true) in
            print(self.posts[0].userID)
            if self.posts[0].userID != self.uid {
                self.followerButton.isHidden = false
            } else {
                self.followerButton.isHidden = true
            }
            self.sortFirebaseInfo()
            self.getStars()
        }
        
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
        postStars { (true) in
            completionHandler(true)
        }
    }
    
    var bajs = 5
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bajs
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentsCell
        cell.commentsNameLabel.text = "Bka kad awdad"
        if commentConter < 2 {
            cell.commentsTextLabel.text = "AWDA DWAD DAwda da dwad adadad ada dad a"
        }else{
             cell.commentsTextLabel.text = "AWDA DWAD DAwda da dwad adadad ada dad ada d adadada dadad AWDA DWAD DAwda da dwad adadad ada dad ada d adadada dadad AWDA DWAD DAwda da dwad adadad ada dad ada d adadada dadad AWDA DWAD DAwda da dwad adadad ada dad ada d adadada dadad AWDA DWAD DAwda da dwad adadad ada dad ada d adadada dadad"
        }
        
        let cellHight = cell.frame.height
        var tableHight = tableView.frame.height

        tableViewConstraintH.constant = tableHight + cellHight
        return cell
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func postStars(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        let dbref = db.reference(withPath: "Users/\(uid)/RatedPosts/\(self.posts[0].postID!)")
        if self.posts[0].postID != nil && starsHighlighted != 0 {
            let ratedPosts = ["Stars" : starsHighlighted] as [String : Any]
            dbref.updateChildValues(ratedPosts)
            completionHandler(true)
        } else {
            print("\n No postID found or starHighlighted is 0 \n")
            completionHandler(false)
        }
    }
    
    func getStars() {
        let getInfo = User()
        let dbref = Database.database().reference(withPath: "Users/\(uid)/RatedPosts/\(self.posts[0].postID!)")
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let firstSnapshot = snapshot.value as? [String : Any] {
                getInfo.stars = firstSnapshot["Stars"] as? Int
                self.starsHighlighted = getInfo.stars
                
                print("\n Stars: \(self.starsHighlighted) \n")
                
                for button in self.starButtons {
                    for i in 1...self.starsHighlighted-1 {
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
    
    func getUserProfileImage(uid: String) {
        let getInfo = User()
        let dbref = Database.database().reference(withPath: "Users/\(uid)")
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let firstSnapshot = snapshot.value as? [String : Any] {
                getInfo.profileImageURL = firstSnapshot["profileImageURL"] as? String
                
                if getInfo.profileImageURL != ""  {
                    self.subviewProfileImage.downloadImage(from: getInfo.profileImageURL)
                } else {
                    print("\n profileImageURL not found \n")
                    return
                }
            }
        })
    }
    
    func downloadInfo(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        let dbref = Database.database().reference().child("Posts").child("\(seguePostID!)")
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let getInfo = Post()
                getInfo.pathToImage = dictionary["pathToImage"] as! String
                getInfo.rating = dictionary["rating"] as! Int
                getInfo.userID = dictionary["userID"] as! String
                getInfo.postID = dictionary["postID"] as! String
                getInfo.alias = dictionary["alias"] as! String
                getInfo.imgdescription = dictionary["imgdescription"] as! String
                getInfo.vegi = dictionary["vegetarian"] as? Bool
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
        print("comment click")
        commentsView.isHidden = false
        commentsTextField.becomeFirstResponder()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if commentsTextField.text != "" {
            // Skicka data
            
            self.commentsTextField.resignFirstResponder()
            self.view.endEditing(true)
            self.commentsView.isHidden = true
            AppDelegate.instance().dismissActivityIndicator()
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
        pointsLabel.text = "\(self.posts[0].rating!) Rating"
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
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func starButtonsTapped(_ sender: UIButton) {
        starsHighlighted = sender.tag + 1
        print(starsHighlighted)
        
        for button in starButtons {
            button.setImage(#imageLiteral(resourceName: "emptystar30"), for: .normal)
            
            if button.tag <= starsHighlighted-1 {
                button.setImage(#imageLiteral(resourceName: "fullstar30"), for: .normal)
            }
        }
    }
    
    func appendToFirebase() {
        let dbRef = Database.database().reference(withPath: "Posts/\(seguePostID)/stars")
        if starsHighlighted > 0 {
            let feed = ["\(starsHighlighted)" : +1] as [String : Any]
            dbRef.updateChildValues(feed)
        }
    }
    
    @IBAction func clickedOnUsername(_ sender: Any) {
        subviewBackground.isHidden = false
        subview.isHidden = false
        self.subviewFollowButton.isHidden = false
        self.subviewUsername.text = self.posts[0].alias        
        let selectedUser = self.posts[0].userID
        downloadImages(uid: selectedUser!)
        getUserProfileImage(uid: selectedUser!)
        
    }
    ///////////////////////////////////SUBVIEW//////////////////////////////////////////////
    
    @IBAction func subviewFollowBtn(_ sender: Any) {
        getFollower()
        addFollower()
    }

    func downloadImages(uid: String) {
        posts.removeAll()
        let dbref = Database.database().reference(withPath: "Users/\(uid)/Posts")
        dbref.queryOrderedByKey().queryLimited(toFirst: 100).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                for (_, post) in dictionary {
                    let appendPost = Post()
                    appendPost.pathToImage256 = post["pathToImage256"] as? String
                    appendPost.postID = post["postID"] as? String
                    appendPost.vegi = post["vegetarian"] as? Bool
                    self.posts.insert(appendPost, at: 0)
                }
            }
            self.subviewCollectionFeed.reloadData()
        })
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePageSubviewCell", for: indexPath) as! ImagePageSubViewCell
        
        cell.mySubviewCollectionFeed.image = nil
        if self.posts[indexPath.row].pathToImage256 != nil {
            cell.mySubviewCollectionFeed.downloadImage(from: self.posts[indexPath.row].pathToImage256)
        } else {
            print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
        }
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
        subviewBackground.isHidden = true
        subview.isHidden = true
    }
    
}
