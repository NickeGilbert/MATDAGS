//
//  ImagePageSubViewExt.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-02-15.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit
import Firebase

extension ImagePageVC {
    
    @IBAction func subviewFollowBtn(_ sender: Any) {
        subviewFollowButton.isHidden = true
        followerButton.isHidden = true
        unfollowingButton.isHidden = false
        subviewUnfollowButton.isHidden = false
        getFollower()
        addFollower()
    }
    
    
    @IBAction func subviewUnfollowUser(_ sender: Any) {
        subviewFollowButton.isHidden = false
        followerButton.isHidden = false
        unfollowingButton.isHidden = true
        subviewUnfollowButton.isHidden = true
        unfollowUser()
    }
    

    func getUserProfileImage(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        if subviews.count == 0 {
            let getInfo = User()
            let puid = self.posts[0].userID!
            let dbref = Database.database().reference(withPath: "Users/\(puid)")
            dbref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let firstSnapshot = snapshot.value as? [String : Any] {
                    getInfo.profileImageURL = firstSnapshot["profileImageURL"] as? String
                    if getInfo.profileImageURL != ""  {
                        self.subviewProfileImage.downloadImage(from: getInfo.profileImageURL)
                        completionHandler(true)
                        print("\nHämtade profilbild")
                    } else {
                        completionHandler(true)
                        print("\n profileImageURL not found \n")
                        return
                    }
                } else {
                    print("\nCouldnt fetch profile image for subview.")
                    completionHandler(true)
                }
            })
        } else {
            completionHandler(true)
        }
    }
    
    func downloadImages(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        if subviews.count == 0 {
            subviews.removeAll()
            let puid = self.posts[0].userID!
            let dbref = Database.database().reference(withPath: "Users/\(puid)/Posts")
            dbref.queryOrderedByKey().queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    for (_, post) in dictionary {
                        let appendPost = Subview()
                        appendPost.pathToImage256 = post["pathToImage256"] as? String
                        appendPost.postID = post["postID"] as? String
                        appendPost.vegi = post["vegetarian"] as? Bool
                        self.subviews.append(appendPost)
                        completionHandler(true)
                    }
                } else {
                    completionHandler(true)
                    print("\nCouldnt download data for subview.")
                }
                self.subviewCollectionFeed.reloadData()
            })
        } else {
            completionHandler(true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePageSubviewCell", for: indexPath) as! ImagePageSubViewCell
        
        let cachedImages = cell.viewWithTag(1) as? UIImageView
        cell.layer.cornerRadius = 5
        cell.mySubviewCollectionFeed.image = nil
        if self.subviews[indexPath.row].pathToImage256 != nil {
            cell.mySubviewCollectionFeed.downloadImage(from: self.subviews[indexPath.row].pathToImage256)
        } else {
            print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
        }
        
        cachedImages?.sd_setImage(with: URL(string: self.subviews[indexPath.row].pathToImage256))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let size = CGSize(width: view.frame.width/3.5, height: view.frame.width/3.5)
        return size
    }

//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "imagePageSubviewSegue", sender: indexPath)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if(segue.identifier == "imagePageSubviewSegue")
//        {
//            let selectedCell = sender as! NSIndexPath
//            let selectedRow = selectedCell.row
//            let imagePage = segue.destination as! ImagePageVC
//            imagePage.seguePostID = self.posts[selectedRow].postID
//        } else {
//            print("\n Segue with identifier (imagePage) not found. \n")
//        }
//    }
    
    @IBAction func closeCommentButton(_ sender: UIButton) {
        commentsView.isHidden = true
        self.view.endEditing(true)
    }
    
    @IBAction func closeSubview(_ sender: Any) {
        topSubView.isHidden = true
    }
    
}
