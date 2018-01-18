//  FollowersVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-10-17.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase

class FollowersVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var feedCollectionView: UICollectionView!
    
    var ref: DatabaseReference!
    var posts = [Post]()
    var users = [User]()
    var seguePostID : String!
    var following = [String]()
    var refresher : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        AppDelegate.instance().showActivityIndicator()
        
        self.refresher = UIRefreshControl()
        self.feedCollectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.clear
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.feedCollectionView!.addSubview(refresher)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        

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
//        posts.removeAll()
//        self.following.removeAll()
        fetchPosts()
//        loadData()
//        AppDelegate.instance().dismissActivityIndicator()
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
                            let postsSnap = snap.value as! [String: AnyObject]
                            
                            for (_,post) in postsSnap {
                                if let userID = post["userID"] as? String {
                                    for each in self.following {
                                        if each == userID {
                                            let posst = Post()
                                            posst.vegi = post["vegetarian"] as? Bool
                                            if let alias = post["alias"] as? String, let rating = post["rating"] as? Int, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String {
                                                
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
        
        cell.imageFeedView.image = nil
        cell.imageFeedView.downloadImage(from: self.posts[indexPath.row].pathToImage)
        cell.usernameLabel.text = self.posts[indexPath.row].alias
//        cell.layer.borderColor = UIColor.lightGray.cgColor
//        cell.layer.borderWidth = 1
        cell.backgroundColor = UIColor.white
        cell.dropShadow()
        
        cell.vegiIcon.isHidden = true
        
        if self.posts[indexPath.row].vegi == nil || self.posts[indexPath.row].vegi == false {
            cell.vegiIcon.isHidden = true
        }else{
            cell.vegiIcon.isHidden = false
        }
        
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

