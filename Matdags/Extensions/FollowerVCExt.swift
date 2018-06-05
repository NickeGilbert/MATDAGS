//
//  FollowerVCExt.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-01-18.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit
import Firebase

extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 1
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension FollowersVC {
    //SUBVIEW
    func getUserProfileImage(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        if subviews.count == 0 {
            let getInfo = User()
            let puid = Auth.auth().currentUser?.uid
            let dbref = Database.database().reference(withPath: "Users/\(puid)")
            dbref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let firstSnapshot = snapshot.value as? [String : Any] {
                    getInfo.profileImageURL = firstSnapshot["profileImageURL"] as? String
                    if getInfo.profileImageURL != ""  {
                        self.subviewProfileImage.downloadImage(from: getInfo.profileImageURL)
                        print("PROFILBILD: ", self.subviewProfileImage!)
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
            
            //Här får vi vilka användare som finns hos oss!
            self.following.append(Auth.auth().currentUser!.uid)
            print("HEJSAN: ", self.following)
            
            
            
            let puid = Auth.auth().currentUser!.uid
            print("puid", puid)
            let userUID = self.posts[0].postID
            print("userID posts", userUID)
            
            
            
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
                self.subviewCollectionView.reloadData()
                self.feedCollectionView.reloadData()
            })
        } else {
            completionHandler(true)
        }
    }
    
    func getUserUID() {
        
    }
    
}
