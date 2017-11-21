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
    var likes = ""
    var posts = [Post]()
    var starHighlited = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadInfo { (true) in
            self.sortFirebaseInfo()
        }
    }
    
    func downloadInfo(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        print("\n seguePostID: \(seguePostID!) \n")
        let database = Database.database().reference().child("Posts").child(seguePostID)
        database.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    print("\n Firebase Dictionary error at ImagePageVC. \n")
                    return
                }
                let getInfo = Post()
                getInfo.pathToImage = dictionary["pathToImage"] as? String
                getInfo.likes = dictionary["likes"] as? Int
                getInfo.userID = dictionary["userID"] as? String
                getInfo.alias = dictionary["alias"] as? String
                getInfo.imgdescription = dictionary["imgdescription"] as? String
                self.posts.append(getInfo)
                completionHandler(true)
                } else {
                print("\n No snapshot children found \n")
                completionHandler(false)
            }
        })
        database.removeAllObservers()
    }
    
    func sortFirebaseInfo() {
        if self.posts[0].pathToImage != nil {
            myImageView.downloadImage(from: self.posts[0].pathToImage)
        } else {
            print("\n No Image URL found in array. \n")
        }
        pointsLabel.text = "\(self.posts[0].likes!) Likes"
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
