//  ImagePageVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-11-05.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase

class ImagePageVC: UIViewController {

    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var starButtons: [UIButton]!
    @IBOutlet weak var followerButton: UIButton!
    
    var seguePostID : String!
    var posts = [Post]()
    var users = [User]()
    var starHighlited = 0
    var countFollowing = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadInfo { (true) in
            if self.posts[0].userID == Auth.auth().currentUser!.uid {
                self.followerButton.isHidden = true
            }
            self.sortFirebaseInfo()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func downloadInfo(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        let dbref = Database.database().reference().child("Posts").child("\(seguePostID!)")
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            let dictionary = snapshot.value as! [String : AnyObject]
            let getInfo = Post()
            //getInfo.setValuesForKeys(dictionary)
            getInfo.pathToImage = dictionary["pathToImage"] as! String
            getInfo.rating = dictionary["rating"] as! Int
            getInfo.userID = dictionary["userID"] as! String
            getInfo.alias = dictionary["alias"] as! String
            getInfo.imgdescription = dictionary["imgdescription"] as! String
            self.posts.append(getInfo)
            completionHandler(true)
        })
    }
    
    @IBAction func followUser(_ sender: Any) {
        addfollower()
        getfollower()
        countPeopleYouFollow()
    }
    
    func countPeopleYouFollow() {
        let uid = Auth.auth().currentUser!.uid
        let dbref = Database.database().reference().child("Users").child("\(uid)").child("YouAreFollowing")
        
        if countFollowing > 0 {
            let counter = ["\(countFollowing)" : +1 ] as [String : Any]
            dbref.updateChildValues(counter)
            print(counter)
        }
    }
    
    func addfollower() {
        //Du följer en användare
        let uid = Auth.auth().currentUser!.uid
        let dbref = Database.database().reference().child("Users").child("\(uid)").child("Following")
        
        if self.posts[0] != nil {
            let following = ["\(self.posts[0].alias!)" : self.posts[0].userID!] as [String : Any]
            dbref.updateChildValues(following)
        } else {
            print("HÄMTAR INGENTING")
        }
    }
    
    func getfollower() {
        //Användaren får att du följer honom
        let uid = Auth.auth().currentUser!.uid
        let alias = Auth.auth().currentUser!.displayName
        let dbref = Database.database().reference().child("Users").child("\(posts[0].userID!)").child("Follower")
        
        let follower = ["\(alias!)" : "\(uid)" ] as [String : Any]
        dbref.updateChildValues(follower)
        
    }

    func sortFirebaseInfo() {
        if self.posts[0].pathToImage != nil {
            myImageView.downloadImage(from: self.posts[0].pathToImage)
        } else {
            print("\n No Image URL found in array. \n")
        }
        pointsLabel.text = "\(self.posts[0].rating!) Rating"
        if posts[0].alias != nil{
            usernameLabel.text = self.posts[0].alias
        } else {
            usernameLabel.text = self.posts[0].userID
        }
        if self.posts[0].imgdescription != nil {
            descriptionLabel.text = self.posts[0].imgdescription
        } else {
            descriptionLabel.text = "Ingen beskrivning."
        }
    }
    
    @IBAction func imagePageBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func starButtonsTapped(_ sender: UIButton) {
        starHighlited = sender.tag + 1
        print(starHighlited)
        
        for button in starButtons {
            button.setImage(#imageLiteral(resourceName: "emptystar30"), for: .normal)
            
            if button.tag <= starHighlited-1 {
                button.setImage(#imageLiteral(resourceName: "fullstar30"), for: .normal)
            }
        }
    }
    
    func appendToFirebase() {
        let dbRef = Database.database().reference(withPath: "Posts/\(seguePostID)/stars")
        if starHighlited > 0 {
            let feed = ["\(starHighlited)" : +1] as [String : Any]
            dbRef.updateChildValues(feed)
        }
    }
}
