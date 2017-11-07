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
   
    var likes = ""
    var posts = [Post]()
    
    @IBOutlet var collectionFeed: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadLikes()
        pointsLabel.text = likes
    }
    
    func downloadLikes() {
        
        let dbref = Database.database().reference()
        
        dbref.child("Posts").observe(.childAdded, with: { (snapshot) in
            let dictionary = snapshot.value as? NSDictionary
            
            if let item = dictionary?["Likes"] as? String
            {
                self.likes.append(item)
                print(item)
            }
            else
            {
                self.likes.append("")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
