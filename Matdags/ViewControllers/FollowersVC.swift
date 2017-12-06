//  FollowersVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-10-17.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase

class FollowersVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var feedCollectionView: UICollectionView!
    
    var ref: DatabaseReference!
    var feedArray = [FollowersCell]()    
    var posts = [Post]()
    var count:Int! = 0
    var lastCount:Int! = 0
    var users = [User]()
    var seguePostID : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func downloadInfo(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        let dbref = Database.database().reference().child("Users").child("Following").child("\(seguePostID!)")
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            let dictionary = snapshot.value as! [String : AnyObject]
            let getInfo = Post()
            getInfo.pathToImage = dictionary["pathToImage"] as! String
            getInfo.alias = dictionary["alias"] as! String
            self.posts.append(getInfo)
            completionHandler(true)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return 10 //Ska vara feedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "followersCell", for: indexPath) as! FollowersCell
        return cell
    }
}
