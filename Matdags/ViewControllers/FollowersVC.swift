    //  FollowersVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-10-17.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase

class FollowersVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var feedCollectionView: UICollectionView!
    @IBOutlet weak var zeroImagesMessage: UILabel!
    @IBOutlet weak var subviewCollectionView: UICollectionView!
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var subviewUsername: UILabel!
    @IBOutlet weak var subviewProfileImage: UIImageView!
    
    var ref: DatabaseReference!
    var posts = [Post]()
    var users = [User]()
    var seguePostID : String!
    var following = [String]()
    var refresher : UIRefreshControl!
    var subviews = [Subview]()
    
    let uid = Auth.auth().currentUser!.uid
    let db = Database.database()
    let alias = Auth.auth().currentUser!.displayName
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //subview.layer.cornerRadius = 20
       // subview.clipsToBounds = true
        self.subview.isHidden = true
        self.zeroImagesMessage.isHidden = true
        
        if posts.isEmpty == true {
            
            zeroImagesMessage.isHidden = false
            zeroImagesMessage.text = zeroImages
        }
        
        self.refresher = UIRefreshControl()
        self.feedCollectionView!.alwaysBounceVertical = true
//        self.refresher.tintColor = UIColor.clear
        self.refresher.tintColor = UIColor.orange
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.feedCollectionView!.addSubview(refresher)
        self.feedCollectionView.delegate = self
        self.feedCollectionView.dataSource = self
        self.subviewCollectionView.delegate = self
        self.subviewCollectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if posts.isEmpty {
            loadData()
            zeroImagesMessage.isHidden = true
        }else{
            self.posts.removeAll()
            loadData()
            self.refresher.beginRefreshing()
        }
    }
    
    @objc func loadData() {
        fetchPosts { (true) in
            self.posts.sort(by: {$0.date > $1.date})
            self.feedCollectionView.reloadData()
            self.subviewCollectionView.reloadData()
            self.stopRefresher()
            print(self.posts.count)
        }
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        getUserProfileImage { (true) in
            self.downloadImages(completionHandler: { (true) in
                self.subviewCollectionView.reloadData()
                self.subview.isHidden = false
            })
        }
        
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    func fetchPosts(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        self.posts.removeAll()
        self.following.removeAll()
        
        let ref = Database.database().reference()
        
        ref.child("Users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if let Users = snapshot.value as? [String : AnyObject] {
                for (_,value) in Users {
                    if let ID = value["uid"] as? String {
                        if ID == Auth.auth().currentUser?.uid {
                            if let followingUsers = value["Following"] as? [String: String] {
                                for (_,user) in followingUsers {
                                    self.following.append(user)
                                }
                            }
                            self.following.append(Auth.auth().currentUser!.uid)
                            
                            ref.child("Posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
                                if let postsSnap = snap.value as? [String: AnyObject] {
                                    for (_,post) in postsSnap {
                                        if let userID = post["userID"] as? String {
                                            for each in self.following {
                                                if each == userID {
                                                    let appendPost = Post()
                                                    
                                                    appendPost.date = post["date"] as? String
                                                    appendPost.alias = post["alias"] as? String
                                                    appendPost.rating = post["rating"] as? Double
                                                    appendPost.pathToImage = post["pathToImage"] as? String
                                                    appendPost.postID = post["postID"] as? String
                                                    appendPost.vegi = post["vegetarian"] as? Bool
                                                    appendPost.usersRated = post["usersRated"] as? Double
                                                    
                                                    self.posts.append(appendPost)
                                                    self.zeroImagesMessage.isHidden = true
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    print("\nNo Posts found in db.")
                                }
                                completionHandler(true)
                            })
                        }
                    }
                }
            } else {
                completionHandler(true)
                print("\nCouldnt fetch Posts in FollowerVC.")
            }
        })
        ref.removeAllObservers()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if collectionView == feedCollectionView {
                print("POSTS: ", self.posts.count)
            return self.posts.count
        
        } else {
              print("SUBVIEWS: ", self.subviews.count)
            return self.subviews.count
          
        }
   
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.feedCollectionView {
            let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "followersCell", for: indexPath) as! FollowersCell
            
            let cachedImages = cell.viewWithTag(1) as? UIImageView
            
            cell.imageFeedView.image = nil
            
            if self.posts[indexPath.row].pathToImage != nil {
                cell.imageFeedView.downloadImage(from: self.posts[indexPath.row].pathToImage)
            }
            
            //Visa stjärnor i varje cell
            let rating = self.posts[indexPath.row].rating
            let usersrated = self.posts[indexPath.row].usersRated
            if rating != nil {
                for button in cell.starButtonArray {
                    button.setImage(#imageLiteral(resourceName: "emptystar30"), for: .normal)
                    if Int(rating!) > 0 {
                        if Int(usersrated!) > 0 {
                            let a = rating! / usersrated!
                            for i in 0...Int(a)-1 {
                                if button.tag <= i {
                                    button.setImage(#imageLiteral(resourceName: "fullstar30"), for: .normal)
                                }
                            }
                        }
                    }
                }
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(FollowersVC.tapFunction))
            cell.usernameLabel.isUserInteractionEnabled = true
            cell.usernameLabel.addGestureRecognizer(tap)
            
            cell.usernameLabel.text = self.posts[indexPath.row].alias
            subviewUsername.text = cell.usernameLabel.text
            print("NAME1: ", subviewUsername.text!)
            
            cell.backgroundColor = UIColor.white
            //        cell.dropShadow()
            cell.vegiIcon.isHidden = true
            
            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
            
            if self.posts[indexPath.row].vegi == nil || self.posts[indexPath.row].vegi == false {
                cell.vegiIcon.isHidden = true
            } else {
                cell.vegiIcon.isHidden = false
            }
            
            cachedImages?.sd_setImage(with: URL(string: self.posts[indexPath.row].pathToImage))
            return cell
        } else {
            
            let cellB = subviewCollectionView.dequeueReusableCell(withReuseIdentifier: "subviewFollowersCell", for: indexPath) as! FollowerSubViewCell
            
            cellB.layer.cornerRadius = 5
            cellB.mySubviewCollectionFeed.image = nil
            if self.subviews[indexPath.row].pathToImage256 != nil {
                cellB.mySubviewCollectionFeed.downloadImage(from: self.subviews[indexPath.row].pathToImage256)
            } else {
                print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
            }
            return cellB
        }
    }
        
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == feedCollectionView {
            let storleken = CGSize(width: self.view.frame.width - 20, height: self.view.frame.width + 100)
            return storleken
        } else {
            let size = CGSize(width: self.view.frame.width/3.5, height: self.view.frame.width/3.5)
            return size
        }
       
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        tabBarController?.selectedIndex = 2
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        URLCache.shared.removeAllCachedResponses()
    }
    
    @IBAction func subviewDismissBtn(_ sender: Any) {
        subview.isHidden = true
    }
    
}

