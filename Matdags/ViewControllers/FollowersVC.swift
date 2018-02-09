    //  FollowersVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-10-17.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase

class FollowersVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var feedCollectionView: UICollectionView!
    @IBOutlet weak var zeroImagesMessage: UILabel!
    
    var ref: DatabaseReference!
    var posts = [Post]()
    var users = [User]()
    var seguePostID : String!
    var following = [String]()
    var refresher : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.zeroImagesMessage.isHidden = true
        self.refresher = UIRefreshControl()
        self.feedCollectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.clear
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.feedCollectionView!.addSubview(refresher)
        
        //Används ej? Kevin
        //let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        //let width = UIScreen.main.bounds.width
    }
    
    @objc func loadData() {
        posts.removeAll()
        fetchPosts()
        self.feedCollectionView.reloadData()
        stopRefresher()
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchPosts()
    }
    
    func fetchPosts() {
        self.posts.removeAll()
        self.following.removeAll()
        AppDelegate.instance().showActivityIndicator()
        let ref = Database.database().reference()
        
        ref.child("Users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            let Users = snapshot.value as! [String: AnyObject]
            
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
                                                let posst = Post()
                                                posst.vegi = post["vegetarian"] as? Bool
                                                if let alias = post["alias"] as? String, let rating = post["rating"] as? Double, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String {
                                                    
                                                    posst.alias = alias
                                                    posst.rating = rating
                                                    posst.pathToImage = pathToImage
                                                    posst.postID = postID
                                                    posst.userID = userID
                                                    
                                                    self.posts.append(posst)
                                                }
                                            }
                                        }
                                        self.feedCollectionView.reloadData()
                                        AppDelegate.instance().dismissActivityIndicator()
                                    }
                                }
                            } else {
                                print("\nNo Posts found in db.")
                                AppDelegate.instance().dismissActivityIndicator()
                            }
                        })
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.posts.count
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.posts.removeAll()
        self.following.removeAll()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "followersCell", for: indexPath) as! FollowersCell
        
        let cachedImages = cell.viewWithTag(1) as? UIImageView
        
        cell.layer.cornerRadius = 2
        cell.clipsToBounds = true
        
        cell.imageFeedView.image = nil
        
        if self.posts[indexPath.row].pathToImage != nil {
            cell.imageFeedView.downloadImage(from: self.posts[indexPath.row].pathToImage)
        } else {
        }
        
        cell.usernameLabel.text = self.posts[indexPath.row].alias
        cell.backgroundColor = UIColor.white
        cell.dropShadow()
        cell.vegiIcon.isHidden = true
        
        if self.posts[indexPath.row].vegi == nil || self.posts[indexPath.row].vegi == false {
            cell.vegiIcon.isHidden = true
        }else{
            cell.vegiIcon.isHidden = false
        }
        
        cachedImages?.sd_setImage(with: URL(string: self.posts[indexPath.row].pathToImage))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let storleken = CGSize(width: self.view.frame.width - 20, height: self.view.frame.width + 100)
        return storleken
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        tabBarController?.selectedIndex = 2
    }
}

