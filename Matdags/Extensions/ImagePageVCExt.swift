//  ImagePageVCExt.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2018-02-15.
//  Copyright © 2018 Matdags. All rights reserved.

import UIKit
import Firebase

extension ImagePageVC {
    
    func addFollower() {
        let dbref = db.reference(withPath: "Users/\(uid)/Following")
        let uref = db.reference(withPath: "Users/\(uid)")
        if self.posts[0].userID != nil {
            let following = ["\(self.posts[0].alias!)" : self.posts[0].userID!] as [String : Any]
            
            peoplelIFollowCount = peoplelIFollowCount+1
            let counter = ["followingCounter" : peoplelIFollowCount ] as [String : Int]
            uref.updateChildValues(counter)
            dbref.updateChildValues(following)
        } else {
            print("\n userID not found when adding follower \n")
        }
    }
    
    func getFollower() {
        let followerid = posts[0].userID
        let dbref = db.reference(withPath: "Users/\(followerid!)/Follower")
        let userRef = db.reference(withPath: "Users/\(followerid!)")
        if self.posts[0].userID != nil {
            let follower = ["\(alias!)" : "\(uid)" ] as [String : Any]
            
            countPeopleThatFollowMe = countPeopleThatFollowMe+1
            let counter = ["followerCounter" : countPeopleThatFollowMe ] as [String : Int]
            userRef.updateChildValues(counter)
            dbref.updateChildValues(follower)
            
        } else {
            
        }
    }
    
    func unfollowUser() {
        let followerId = posts[0].userID!
        let followingid = posts[0].alias
        let userRef = db.reference(withPath: "Users/\(followerId)")
        let uref = db.reference(withPath: "Users/\(uid)")
        let mySelf = Auth.auth().currentUser!.displayName!
        
        let dbref = db.reference(withPath: "Users/\(uid)/Following/\(followingid!)")
        peoplelIFollowCount = peoplelIFollowCount-1
        let counter = ["followingCounter" : peoplelIFollowCount ] as [String : Int]
        uref.updateChildValues(counter)
        
        dbref.removeValue { (error, ref) in
            if error != nil {
                print("DIDN'T GO THROUGH")
                return
            }
        }
        
        let dbUserRef = db.reference(withPath: "Users/\(followerId)/Follower/\(mySelf)")
        
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
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getUserThatFollowMeCounter() {
        let ref = Database.database().reference()
        let followerid = posts[0].userID
        ref.child("Users").child(followerid!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.countPeopleThatFollowMe = value?["followerCounter"] as? Int ?? -1
        }) { (error) in
            print(error.localizedDescription)
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
                let postStars = ["rating" : postRating - fetchedStars + a] as [String : Int]
                dbref.updateChildValues(postStars)
            } else if starsHighlighted > fetchedStars {
                let postStars = ["rating" : postRating - fetchedStars + b] as [String : Int]
                dbref.updateChildValues(postStars)
            }
            
            if fetchedStars == 0 && starsHighlighted != 0 {
                usersRated+=1
                dbref.updateChildValues(["usersRated" : usersRated] as [String : Int])
            }
            completionHandler(true)
        } else {
            completionHandler(true)
        }
    }
    
    func getStars() {
        //Get number of stars
        let getInfo = User()
        let uref = Database.database().reference(withPath: "Users/\(uid)/RatedPosts/\(seguePostID!)")
        uref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                getInfo.stars = dict["Stars"] as? Int ?? 1
                self.starsHighlighted = getInfo.stars
                self.fetchedStars = getInfo.stars
                for button in self.starButtons {
                    for i in 0...self.starsHighlighted-1 {
                        if button.tag <= i {
                            button.setImage(#imageLiteral(resourceName: "YellowStarUSE"), for: .normal)
                        }
                    }
                }
            } else {
            }
        })
    }
    
    @IBAction func starButtonsTapped(_ sender: UIButton) {
        starsHighlighted = sender.tag + 1
        print(starsHighlighted)
        
        for button in starButtons {
            button.setImage(#imageLiteral(resourceName: "GrayStarUSE"), for: .normal)
            
            if button.tag <= starsHighlighted-1 {
                button.setImage(#imageLiteral(resourceName: "YellowStarUSE"), for: .normal)
            }
        }
    }
    
    
    // new test with swipe down getsuers below daniel
    
    func slideViewVerticallyTo(_ y: CGFloat) {
        self.view.frame.origin = CGPoint(x: 0, y: y)
    }
    
    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began, .changed:
            let translation = panGesture.translation(in: view)
            let y = max(0, translation.y)
            self.slideViewVerticallyTo(y)
            break
        case .ended:
            let translation = panGesture.translation(in: view)
            let velocity = panGesture.velocity(in: view)
            let closing = (translation.y > self.scrollView.frame.size.height * minimumScreenRatioToHide) ||
                (velocity.y > minimumVelocityToHide)
            
            if closing {
                UIView.animate(withDuration: animationDuration, animations: {
                    self.slideViewVerticallyTo(self.view.frame.size.height)
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.customWillDisappear(in: self.dispatchGroup, completionHandler: { (true) in
                            self.posts.removeAll()
                            self.subviews.removeAll()
                            self.commentsRef.removeAllObservers()
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                })
            } else {
                UIView.animate(withDuration: animationDuration, animations: {
                    self.slideViewVerticallyTo(0)
                })
            }
            break
        default:
            UIView.animate(withDuration: animationDuration, animations: {
                self.slideViewVerticallyTo(0)
            })
            break
        }
    }
    
    
}
