//
//  FollowersVC.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2017-10-17.
//  Copyright © 2017 Matdags. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FollowersVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var feedCollectionView: UICollectionView!
    
    var ref: DatabaseReference!
    var feedArray = [Images]()
    let cellIdentifier = "cell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      /*  ref = Database.database().reference()
        if let uid = Auth.auth().currentUser?.uid{
            //To get the users we are following
            ref.child("Followers").child(uid).observe(.value, with: { (followingSnapshot) in
                //Store values in dictionary
                let followingDictionary = followingSnapshot.value as! NSDictionary
                for (id, _) in followingDictionary {
                    //To get the users who are following images
                    let userPostRef = self.ref.child("Post").child(id as! String) //Kolla ifall Matdags stämmer
                    userPostRef.observe(.value, with: { (postSnapshots) in
                        //Store values in a dictionary
                        let postDictionary = postSnapshots.value as! NSDictionary
                        for(p) in postDictionary {
                            let posts = p.value as! NSDictionary
                            //get profile photo url => profile_pic
                            guard let profileUrl = posts.value(forKey: "profile_pic") else{return}
                            //get username Key => username
                            guard let username = posts.value(forKey: "username") else{return} //posts ska kanske vara Images
                            //get post url Key => posted_pic
                            guard let postUrl = posts.value(forKey: "posted_pic") else{return} //posts ska kanske vara Images
                            
                            let newPost: Images = Images(profilePic: profileUrl as! String, username: username as! String, postImage: postUrl as! String)
                            self.feedArray.append(newPost)
                        }
                    })
                }
            })
        }*/
    }
        
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return feedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! FollowersCVCell
        
        return cell
    }
}
