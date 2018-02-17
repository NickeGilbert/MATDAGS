//
//  ImagePageVCExt.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-02-15.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit
import Firebase

extension ImagePageVC {
    
    func addFollower() {
        let dbref = db.reference(withPath: "Users/\(uid)/Following")
        let uref = db.reference(withPath: "Users/\(uid)")
        if self.posts[0].userID != nil {
            let following = ["\(self.posts[0].alias!)" : self.posts[0].userID!] as [String : Any]
            
            count+=1
            let counter = ["followingCounter" : count ] as [String : Int]
            uref.updateChildValues(counter)
            dbref.updateChildValues(following)
        } else {
            print("\n userID not found when adding follower \n")
        }
    }
    
    func getFollower() {
        let followerid = posts[0].userID
        let dbref = db.reference(withPath: "Users/\(followerid!)/Follower")
        let uref = db.reference(withPath: "Users/\(uid)")
        if self.posts[0].userID != nil {
            let follower = ["\(alias!)" : "\(uid)" ] as [String : Any]
            
            countFollower+=1
            let counter = ["followerCounter" : countFollower ] as [String : Int]
            uref.updateChildValues(counter)
            dbref.updateChildValues(follower)
        } else {
            print("\n userID not found when getting follower \n")
        }
    }
    
    func postStars(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        if self.posts[0].postID != nil {
            //Post stars to userdb
            let uref = db.reference(withPath: "Users/\(uid)/RatedPosts/\(self.posts[0].postID!)")
            if starsHighlighted != 0 {
                let ratedPosts = ["Stars" : starsHighlighted] as [String : Any]
                uref.updateChildValues(ratedPosts)
            }
            
            //Post stars to postdb
            let dbref = db.reference(withPath: "Posts/\(self.posts[0].postID!)")
            let a = fetchedStars - (fetchedStars - starsHighlighted)
            let b = fetchedStars + (starsHighlighted - fetchedStars)
            if starsHighlighted < fetchedStars {
                let postStars = ["rating" : postRating - fetchedStars + a] as [String : Double]
                dbref.updateChildValues(postStars)
            } else if starsHighlighted > fetchedStars {
                let postStars = ["rating" : postRating - fetchedStars + b] as [String : Double]
                dbref.updateChildValues(postStars)
            }
            
            if fetchedStars == 0 && starsHighlighted != 0 {
                usersRated+=1
                dbref.updateChildValues(["usersRated" : usersRated] as [String : Double])
            }
            print("\npostStars true")
            completionHandler(true)
        } else {
            print("\nNo PostID found!")
            completionHandler(true)
        }
    }
    
    func getStars() {
        //Get number of stars
        let getInfo = User()
        let uref = Database.database().reference(withPath: "Users/\(uid)/RatedPosts/\(self.posts[0].postID!)")
        uref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let firstSnapshot = snapshot.value as? [String : Any] {
                getInfo.stars = firstSnapshot["Stars"] as? Int
                self.starsHighlighted = Double(getInfo.stars)
                self.fetchedStars = Double(getInfo.stars)
                for button in self.starButtons {
                    for i in 0...Int(self.starsHighlighted)-1 {
                        if button.tag <= i {
                            button.setImage(#imageLiteral(resourceName: "fullstar30"), for: .normal)
                        }
                    }
                }
            } else {
                print("\n Cant find rating for post. \n")
            }
        })
    }
    
    @IBAction func starButtonsTapped(_ sender: UIButton) {
        starsHighlighted = Double(sender.tag + 1)
        print(starsHighlighted)
        
        for button in starButtons {
            button.setImage(#imageLiteral(resourceName: "emptystar30"), for: .normal)
            
            if Double(button.tag) <= starsHighlighted-1 {
                button.setImage(#imageLiteral(resourceName: "fullstar30"), for: .normal)
            }
        }
    }
    
    
}
