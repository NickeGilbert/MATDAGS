//  ImagePageVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-11-05.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase

class ImagePageVC: UIViewController {

    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var starButtons: [UIButton]!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var seguePostID : String!
    var posts = [Post]()
    var starHighlited = 0
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadInfo { (true) in
            self.sortFirebaseInfo()
        }
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
    }
    
    func addfollower() {
        //Du följer en användare
        
        let database = Database.database().reference().child("Users").childByAutoId()
        let follower = database.key
        
        let newFollower = ["follower_id": follower]
        database.setValue(newFollower)
        //Andra exempel stackoverflow.com/questions/38742782/adding-data-to-a-specific-uid-in-firebase
        
    }
    
    func getfollower() {
        //Användaren får att du följer honom
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
            button.setTitle("☆", for: .normal)
    
            if button.tag <= starHighlited-1 {
                button.setTitle("⭐️", for: .normal)
            }
        }
    }
}
