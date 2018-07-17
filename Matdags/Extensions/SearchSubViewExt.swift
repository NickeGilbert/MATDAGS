//
//  SearchSubViewExt.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-02-15.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit
import Firebase

extension SearchVC {
    
    @IBAction func closeSubview(_ sender: Any) {
        topSubView.isHidden = true
        posts.removeAll()
        self.subviewCollectionFeed.reloadData()
        self.subviewProfileImage.image = nil
        self.subviewUsername.text = nil
        self.searchController.searchBar.isHidden = false
    }
    
    @IBAction func subviewFollowUser(_ sender: Any) {
        self.subviewFollowButton.isHidden = true
        self.subviewUnfollowBtn.isHidden = false
        addFollower()
        getFollower()
        print("PRESSED FOLLOW")
    }
    
    
    @IBAction func unfollowUserButton(_ sender: Any) {
        self.subviewUnfollowBtn.isHidden = true
        self.subviewFollowButton.isHidden = false
        unfollowUser()
    }
    
    func addFollower() {
        let db = Database.database()
        let uid = Auth.auth().currentUser!.uid
        let dbref = db.reference(withPath: "Users/\(uid)/Following")
        let uref = db.reference(withPath: "Users/\(uid)")
        if self.subviewUsername.text != nil {
            let following = ["\(self.subviewUsername.text!)" : "\(userId!)"] as [String : Any]
            
            peoplelIFollowCount = peoplelIFollowCount+1
            let counter = ["followingCounter" : peoplelIFollowCount ] as [String : Int]
            uref.updateChildValues(counter)
            dbref.updateChildValues(following)
            print("4", peoplelIFollowCount)
            print("HEJSAN HEJSAN")
        } else {
            print("\n userID not found when adding follower \n")
        }
    }
    
    func getFollower() {
        let db = Database.database()
        let uid = Auth.auth().currentUser!.uid
        let alias = Auth.auth().currentUser!.displayName
        let followerid = userId!
        let userRef = db.reference(withPath: "Users/\(followerid)")
        let dbref = db.reference(withPath: "Users/\(followerid)/Follower")
        let uref = db.reference(withPath: "Users/\(uid)")
        if userId != nil {
            let follower = ["\(alias!)" : "\(uid)" ] as [String : Any]
            
            countPeopleThatFollowMe = countPeopleThatFollowMe+1
            let counter = ["followerCounter" : countPeopleThatFollowMe ] as [String : Int]
            userRef.updateChildValues(counter)
            dbref.updateChildValues(follower)
        } else {
            print("\n userID not found when getting follower \n")
        }
    }
    
    func unfollowUser() {
        print("PRESSED UNFOLLOW")
        let uid = Auth.auth().currentUser!.uid
        let uref = db.reference(withPath: "Users/\(uid)")
        let followingUsername = self.subviewUsername.text!
        let followingid = userId!
        let userRef = db.reference(withPath: "Users/\(followingid)")
        let mySelf = Auth.auth().currentUser!.displayName!
        
        //Tas bort från sig själv
        let dbref = db.reference(withPath: "Users/\(uid)/Following/\(followingUsername)")
        peoplelIFollowCount = peoplelIFollowCount-1
        let counter = ["followingCounter" : peoplelIFollowCount ] as [String : Int]
        uref.updateChildValues(counter)
        
        dbref.removeValue { (error, ref) in
            if error != nil {
                print("DIDN'T GO THROUGH")
                return
            }
        }

        //Tas bort från den du följer
        let dbUserRef = db.reference(withPath: "Users/\(followingid)/Follower/\(mySelf)")
        
        countPeopleThatFollowMe = countPeopleThatFollowMe-1
        let myFollowersCounter = ["followerCounter" : countPeopleThatFollowMe ] as [String : Int]
        userRef.updateChildValues(myFollowersCounter)

        dbUserRef.removeValue { (error, ref) in
            if error != nil {
                print("DIDN'T GO THROUGH")
                return
            }
        }
    }
    
    func getUserThatIFollowCounter() {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        ref.child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            let value = snapshot.value as? NSDictionary
            self.peoplelIFollowCount = value?["followingCounter"] as? Int ?? -1
            print("PEOPLE IM FOLLOWING", self.peoplelIFollowCount)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getUserThatFollowMeCounter() {
        let ref = Database.database().reference()
        let followerid = userId!
        ref.child("Users").child(followerid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.countPeopleThatFollowMe = value?["followerCounter"] as? Int ?? -1
            print("PEOPLE THAT FOLLOW ME", self.countPeopleThatFollowMe)
        }) { (error) in
            print(error.localizedDescription)
        }
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
        subViewNoImagesLabel.isHidden = true
        noPicturesImageView.isHidden = true
        
        if self.posts.count < 1 {
            subViewNoImagesLabel.isHidden = false
            noPicturesImageView.isHidden = false
        }else{
            subViewNoImagesLabel.isHidden = true
            noPicturesImageView.isHidden = true
        }
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subviewCell", for: indexPath) as! SearchSubViewCell
        cell.mySubviewCollectionFeed.image = nil
        cell.layer.cornerRadius = 5
        if self.posts[indexPath.row].pathToImage256 != nil {
            cell.mySubviewCollectionFeed.downloadImage(from: self.posts[indexPath.row].pathToImage256)
        } else {
            print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width/3.5, height: self.view.frame.width/3.5)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "imagePageSegSubSearch", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "imagePageSegSubSearch")
        {
            let selectedCell = sender as! NSIndexPath
            let selectedRow = selectedCell.row
            let imagePage = segue.destination as! ImagePageVC
            imagePage.seguePostID = self.posts[selectedRow].postID
        } else {
            print("\n Segue with identifier (imagePage) not found. \n")
        }
    }
}
