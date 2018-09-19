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
            print("DBREF: ",dbref)
            dbref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let firstSnapshot = snapshot.value as? [String : Any] {
                    
                    getInfo.userDescription = firstSnapshot["userDescription"] as? String

                    if getInfo.userDescription != ""  {
                        self.descriptionLabelSubView.text = getInfo.userDescription!
                        self.noDiscriptionTextImageView.isHidden = true
                        print("\nHämtade info")
                    } else {
                        self.descriptionLabelSubView.text = "There is no information about this user. Hmmm.. Mysterious indeed"
                        self.descriptionLabelSubView.textColor = UIColor.lightGray
                        self.noDiscriptionTextImageView.isHidden = false
                        print("\n Något fel \n")

                    }
                    
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
//            dbref.queryOrderedByKey().queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { (snapshot) in
            dbref.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
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
    
//    func downloadUserInfo(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
//        if subviews.count == 0 {
//            subviews.removeAll()
//            let puid = self.posts[0].userID!
//            let dbref = Database.database().reference(withPath: "Users/\(puid)/Posts")
//            //            dbref.queryOrderedByKey().queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { (snapshot) in
//            dbref.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
//                if let dictionary = snapshot.value as? [String : AnyObject] {
//                    for (_, post) in dictionary {
//                        let appendPost = Subview()
//                        appendPost.pathToImage256 = post["pathToImage256"] as? String
//                        appendPost.postID = post["postID"] as? String
//                        appendPost.vegi = post["vegetarian"] as? Bool
//
//                        self.subviews.append(appendPost)
//                        completionHandler(true)
//                    }
//                } else {
//                    completionHandler(true)
//                    print("\nCouldnt download data for subview.")
//                }
//                self.subviewCollectionFeed.reloadData()
//            })
//        } else {
//            completionHandler(true)
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("SUBVIEW COUNT: ", self.subviews.count)
        return self.subviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePageSubviewCell", for: indexPath) as! ImagePageSubViewCell
        
        
        let cachedImages = cell.viewWithTag(1) as? UIImageView
        cell.layer.cornerRadius = 5
        cell.mySubviewCollectionFeed.image = nil
        cell.mySubviewCollectionVegiIcon.isHidden = true
        if self.subviews[indexPath.row].vegi == true {
            cell.mySubviewCollectionVegiIcon.isHidden = false
        }
        if self.subviews[indexPath.row].pathToImage256 != nil {
            cell.mySubviewCollectionFeed.downloadImage(from: self.subviews[indexPath.row].pathToImage256)
            
        } else {
            print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
        }
        
        cachedImages?.sd_setImage(with: URL(string: self.subviews[indexPath.row].pathToImage256))
        
        
        zoomedSubviewImage = self.subviews[indexPath.row].pathToImage256
        print(zoomedSubviewImage, "wierd1")
        
       // myImage = self.subviews[indexPath.row].pathToImage256
     //   print(myImage, "HELLO")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let size = CGSize(width: view.frame.width/3.3, height: view.frame.width/3.3)
        return size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//                self.performSegue(withIdentifier: "imagePageSubviewSegue", sender: indexPath)

    }
    
    @objc func handlePress(gesture : UITapGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        
        let g = gesture.location(in: self.subviewCollectionFeed)
        if let indexPath = self.subviewCollectionFeed.indexPathForItem(at: g) {
            let cell = self.subviewCollectionFeed.cellForItem(at: indexPath)
            
            startingFrame = cell?.superview?.convert((cell?.frame)!, to: nil)
            
            let zoomImageView = UIImageView(frame: startingFrame!)
          //  zoomImageView.backgroundColor = UIColor.red
            
            //Här ska det läggas till vilken bild som ska visas men jag vet inte hur jag ska göra det
           // zoomImageView.image
            zoomImageView.downloadImage(from: self.subviews[indexPath.row].pathToImage256)
            print(zoomImageView, "WIERD")
            
            
            zoomImageView.isUserInteractionEnabled = true
            zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
            
            if let keyWindow = UIApplication.shared.keyWindow {
                blackBackgroundView = UIView(frame: keyWindow.frame)
                blackBackgroundView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                blackBackgroundView?.alpha = 0
                keyWindow.addSubview(blackBackgroundView!)
                
                keyWindow.addSubview(zoomImageView)
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self.blackBackgroundView?.alpha = 0.75
                    let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                    
                    zoomImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                    
                    zoomImageView.center = keyWindow.center
                }, completion: nil)
            }
        } else {
            print("couldn't find index path")
        }
    }
    
    @IBAction func closeCommentButton(_ sender: UIButton) {
        commentsView.isHidden = true
        self.view.endEditing(true)
    }
    
    @IBAction func closeSubview(_ sender: Any) {
        closeSubView()
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
            })
        }
    }

    
    
    
    
    
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
}




















