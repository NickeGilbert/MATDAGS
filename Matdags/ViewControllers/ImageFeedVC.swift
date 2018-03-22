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
    
    var posts = [Post]()
    var refresher : UIRefreshControl!
    var isVegi : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        self.refresher = UIRefreshControl()
        self.collectionFeed!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.clear
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionFeed!.addSubview(refresher)
        
    }
    
    @objc func loadData() {
        posts.removeAll()
        downloadImages { (true) in
            self.collectionFeed.reloadData()
            self.stopRefresher()
            print(self.posts.count)
        }
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(Auth.auth().currentUser?.uid == nil) {
            performSegue(withIdentifier: "logout", sender: nil)
        }
    }
    
    func downloadImages(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        let dbref = Database.database().reference(withPath: "Posts")
        dbref.queryLimited(toFirst: 100).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                for (_, post) in dictionary {
                    let appendPost = Post()
                    appendPost.pathToImage256 = post["pathToImage256"] as? String
                    appendPost.postID = post["postID"] as? String
                    appendPost.vegi = post["vegetarian"] as? Bool
                    self.posts.insert(appendPost, at: 0)
                }
            }
            completionHandler(true)
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
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "cameraSeg", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageFeedCell
       
        let cachedImages = cell.viewWithTag(1) as? UIImageView
       
        cell.vegiIcon.isHidden = true
        
        if self.posts[indexPath.row].vegi == false || self.posts[indexPath.row].vegi == nil {
            cell.vegiIcon.isHidden = true
        }else{
            cell.vegiIcon.isHidden = false
        }
        
        cell.myImage.image = nil
        if self.posts[indexPath.row].pathToImage256 != nil {
            cell.myImage.downloadImage(from: self.posts[indexPath.row].pathToImage256)
        } else {
            print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
        }

        cachedImages?.sd_setImage(with: URL(string: self.posts[indexPath.row].pathToImage256))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let storleken = CGSize(width: self.view.frame.width/3.1, height: self.view.frame.width/3.1)
        return storleken
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "imagePageSeg", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "imagePageSeg")
        {
            let selectedCell = sender as! NSIndexPath
            let selectedRow = selectedCell.row
            let imagePage = segue.destination as! ImagePageVC
            imagePage.seguePostID = self.posts[selectedRow].postID
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
