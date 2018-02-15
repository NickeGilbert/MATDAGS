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
        subview.isHidden = true
        self.subviewProfileImage.image = nil
        self.subviewUsername.text = nil
    }
    
    @IBAction func subviewFollowUser(_ sender: Any) {
        addFollower()
        getFollower()
    }
    
    func addFollower() {
        let db = Database.database()
        let uid = Auth.auth().currentUser!.uid
        let dbref = db.reference(withPath: "Users/\(uid)/Following")
        let uref = db.reference(withPath: "Users/\(uid)")
        if self.subviewUsername.text != nil {
            let following = ["\(self.subviewUsername.text!)" : "\(userId)"] as [String : Any]
            
            count+=1
            let counter = ["followingCounter" : count ] as [String : Int]
            uref.updateChildValues(counter)
            dbref.updateChildValues(following)
        } else {
            print("\n userID not found when adding follower \n")
        }
    }
    
    func getFollower() {
        let db = Database.database()
        let uid = Auth.auth().currentUser!.uid
        let alias = Auth.auth().currentUser!.displayName
        let followerid = userId
        let dbref = db.reference(withPath: "Users/\(followerid)/Follower")
        let uref = db.reference(withPath: "Users/\(uid)")
        if userId != nil {
            let follower = ["\(alias!)" : "\(uid)" ] as [String : Any]
            
            countFollower+=1
            let counter = ["followerCounter" : countFollower ] as [String : Int]
            uref.updateChildValues(counter)
            dbref.updateChildValues(follower)
        } else {
            print("\n userID not found when getting follower \n")
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
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subviewCell", for: indexPath) as! SearchSubViewCell
        cell.mySubviewCollectionFeed.image = nil
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
