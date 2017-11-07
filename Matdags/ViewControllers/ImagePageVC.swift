//
//  ImagePageVC.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2017-11-05.
//  Copyright © 2017 Matdags. All rights reserved.
//

import UIKit
import Firebase

class ImagePageVC: UIViewController {

    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var pointsLabel: UILabel!
   
    var likes : Int = 0
    var posts = [Post]()
    
   // var images: img!
    
    @IBOutlet var collectionFeed: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadLikes()
        
        var poäng = String(describing: likes)
        pointsLabel.text = "\(poäng) poäng!"
        //myImageView.image = images.image
    }
    
    func downloadLikes() {
        
        let dbref = Database.database().reference()
        
        dbref.child("Posts").observe(.childAdded, with: { (snapshot) in
            let postsSnaps = snapshot.value as! [String : AnyObject]
            for (_,post) in postsSnaps {
                let appendPost = Post()
                if let likes = post["likes"] as? Int {
                    
                    appendPost.likes = likes
                    print("\(appendPost) POÄNG! ")
                    self.posts.append(appendPost)
                }
            }
        })
    }
    
    @IBAction func imagePageBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
