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
    var feedArray = [FollowersCell]()
    
    var count:Int! = 0
    var lastCount:Int! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*ref = Database.database().reference()
        if let uid = Auth.auth().currentUser?.uid{
            //To get the users we are following
            ref.child("Followers").child(uid).observe(.value, with: { (followersSnapshot) in
                //Store values in dictionary
                let followersDictionary = followersSnapshot.value as! NSDictionary
                for (id, _) in followersDictionary {
                    //To get the users who are following images
                    let userPostRef = self.ref.child("Post").child(id as! String)
                    userPostRef.observe(.childAdded, with: { (postSnapshot) in
                        //Store values in a dictionary
                        if let userPostDictionary = postSnapshot.value as? NSDictionary{
                            let postId = postSnapshot.key
                            if let postData = postSnapshot.value as? NSDictionary{
                            //get profile photo url => profile_pic
                            guard let profileURL = postData["profile_pic"] as! String! else{return}
                            //get username Key => username
                            guard let username = postData["username"] as! String! else{return} //posts ska kanske vara Images
                            //get post url Key => posted_pic
                            guard let postURL = postData["posted_pic"] as! String! else{return} //posts ska kanske vara Images
                            
                            self.feedArray.append(Images(postID: postId, profilePic: profileURL, username: username, postImage: postURL, timestamp: NSNumber(value: Int(NSDate().timeIntervalSince1970))))
                            self.feedCollectionView.reloadData()
                            }
                        }
                    }, withCancel: { (error1) in
                        print(error1)
                    })
                }
            }, withCancel: { (error2) in
                print(error2)
            })
        }*/
    }
    
    @IBAction func kommentarButton(_ sender: Any) {
        performSegue(withIdentifier: "kommentar", sender: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return 10 //Ska vara feedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "followersCell", for: indexPath) as! FollowersCell

        return cell
    }
}
