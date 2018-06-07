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
        
        print("KEBAK1: ", self.peoplelIFollowCount)
        
        let dbref = db.reference(withPath: "Users/\(uid)/Following")
        let uref = db.reference(withPath: "Users/\(uid)")
        if self.posts[0].userID != nil {
            let following = ["\(self.posts[0].alias!)" : self.posts[0].userID!] as [String : Any]
            
            peoplelIFollowCount = peoplelIFollowCount+1
            print("KEBAK2:", peoplelIFollowCount)
            let counter = ["followingCounter" : peoplelIFollowCount ] as [String : Int]
            uref.updateChildValues(counter)
            print("KEBAK3: ", peoplelIFollowCount)
            dbref.updateChildValues(following)
        } else {
            print("\n userID not found when adding follower \n")
        }
    }
    
    func getUserFollowersCounter() {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        ref.child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            let value = snapshot.value as? NSDictionary
            self.peoplelIFollowCount = value?["followingCounter"] as? Int ?? -1
            self.countPeopleThatFollowMe = value?["followerCounter"] as? Int ?? -1
            print("PEOPLE I FOLLOWING", self.peoplelIFollowCount)
            print("PEOPLE I FOLLOWER", self.countPeopleThatFollowMe)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getFollower() {
        let followerid = posts[0].userID
        let dbref = db.reference(withPath: "Users/\(followerid!)/Follower")
        let uref = db.reference(withPath: "Users/\(uid)")
        if self.posts[0].userID != nil {
            let follower = ["\(alias!)" : "\(uid)" ] as [String : Any]
            
            //countFollower+=1
           // let counter = ["followerCounter" : countFollower ] as [String : Int]
         //   uref.updateChildValues(counter)
            dbref.updateChildValues(follower)
        } else {
            print("\n userID not found when getting follower \n")
        }
    }
    
    func unfollowUser() {
        let followerId = posts[0].userID!
        let followingid = posts[0].alias
        let uref = db.reference(withPath: "Users/\(uid)")
        let mySelf = Auth.auth().currentUser!.displayName!
        print("MYSELF", mySelf)
        print("DANIELS UID:", followerId)
        
        //Tas bort från sig själv
        let dbref = db.reference(withPath: "Users/\(uid)/Following/\(followingid!)")
        peoplelIFollowCount = peoplelIFollowCount-1
        print("KEBAK2:", peoplelIFollowCount)
        let counter = ["followingCounter" : peoplelIFollowCount ] as [String : Int]
        uref.updateChildValues(counter)
        print("KEBAK3: ", peoplelIFollowCount)
            print("dbrf: ", dbref)
            dbref.removeValue { (error, ref) in
                if error != nil {
                    print("DIDN'T GO THROUGH")
                    return
                }
            }

        //Tas bort från användaren
        let dbUserRef = db.reference(withPath: "Users/\(followerId)/Follower/\(mySelf)")
     //   countFollower-=1
     //   let Usercounter = ["followerCounter" : countFollower ] as [String : Int]
      //  uref.updateChildValues(Usercounter)
        print("dbrf: ", dbref)
        dbUserRef.removeValue { (error, ref) in
            if error != nil {
                print("DIDN'T GO THROUGH")
                return
            }
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
