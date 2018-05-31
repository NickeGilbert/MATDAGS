//  ImageFeedVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-09-15.
//  Copyright © 2017 Nicklas Gilbertson. All rights reserved.

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit

class ImageFeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    @IBOutlet var collectionFeed: UICollectionView!
    
    let dispatchGroup = DispatchGroup()
    var posts = [Post]()
    var refresher : UIRefreshControl!
    var isVegi : Bool = false
    var cellCounter : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadData()
        
        self.refresher = UIRefreshControl()
        self.collectionFeed!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.clear
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionFeed!.addSubview(refresher)
    }
    
    @objc func loadData() {
        downloadImages(completionHandler: { (true) in
            self.posts.sort(by: {$0.timestamp > $1.timestamp})
            self.collectionFeed.reloadData()
            self.refresher.endRefreshing()
        }, in: dispatchGroup)
        cellCounter = 0
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(Auth.auth().currentUser?.uid == nil) {
            performSegue(withIdentifier: "logout", sender: nil)
        }
        posts.removeAll()
        loadData()
    }
    
    func downloadImages(completionHandler: @escaping ((_ exist : Bool) -> Void), in dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()
        self.posts.removeAll()
        let dbref = Database.database().reference(withPath: "Posts")
        //ToDo: Begränsa queryn till maxantal posts
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                for (_, post) in dictionary {
                    let appendPost = Post()
                    appendPost.date = post["date"] as? String
                    appendPost.pathToImage256 = post["pathToImage256"] as? String
                    appendPost.postID = post["postID"] as? String
                    appendPost.vegi = post["vegetarian"] as? Bool
                    appendPost.timestamp = post["timestamp"] as? String
                    self.posts.append(appendPost)
                }
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main, execute: {
                    print("\n dispatchGroup completed. \n")
                    completionHandler(true)
                })
            }
        })
    }

    @IBAction func loggaOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let loginManager = FBSDKLoginManager()
            loginManager.logOut() // this is an instance function
            performSegue(withIdentifier: "logout", sender: nil)
            print(" \n DU HAR PRECIS LOGGAT UT \n")
        } catch {
            print("\n ERROR NÄR DU LOGGADE UT \n")
        }
    }
    
    @IBAction func camerButtonTouch(_ sender: Any) {
        performSegue(withIdentifier: "cameraSeg", sender: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageFeedCell
       
        let cachedImages = cell.viewWithTag(1) as? UIImageView
       
        cell.vegiIcon.isHidden = true
        cell.myImage.image = nil
        cell.layer.cornerRadius = 5
        
        if self.posts[indexPath.row].vegi == false || self.posts[indexPath.row].vegi == nil {
            cell.vegiIcon.isHidden = true
        } else {
            cell.vegiIcon.isHidden = false
        }
        
        if self.posts[indexPath.row].pathToImage256 != nil {
            cell.myImage.downloadImage(from: self.posts[indexPath.row].pathToImage256)
        } else {
            print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
        }

        cachedImages?.sd_setImage(with: URL(string: self.posts[indexPath.row].pathToImage256))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var storleken = CGSize()

        let n = Int(arc4random_uniform(2))
        let onePart = self.view.frame.width / 3.2
        let twoPart = onePart + onePart + 8

        if cellCounter == 3 {
            if n == 0 {
                storleken = CGSize(width: self.view.frame.width/3.2, height: self.view.frame.width/3.2)
                cellCounter = 1
            } else {
                storleken = CGSize(width: twoPart, height: self.view.frame.width/3.2)
                cellCounter = -1
            }

        }else{
            storleken = CGSize(width: self.view.frame.width/3.2, height: self.view.frame.width/3.2)
            cellCounter += 1
        }
//        print("Storleken : ", storleken)
        return storleken
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        var storleken = CGSize(width: self.view.frame.width/3.2, height: self.view.frame.width/3.2)
//        return storleken
//
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "imagePageSeg", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "imagePageSeg")
        {
            let selectedCell = sender as! NSIndexPath
            let selectedRow = selectedCell.row
            let imagePage = segue.destination as! ImagePageVC
            
            if self.posts[selectedRow].postID != nil {
                imagePage.seguePostID = self.posts[selectedRow].postID
            }

        } else {
            print("\n Segue with identifier (imagePage) not found. \n")
        }
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        print("\nSwiped left.")
        tabBarController?.selectedIndex = 1
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        URLCache.shared.removeAllCachedResponses()
    }
}
