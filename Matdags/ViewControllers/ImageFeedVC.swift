//  ImageFeedVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-09-15.
//  Copyright © 2017 Nicklas Gilbertson. All rights reserved.

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit

class ImageFeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
   
    @IBOutlet var collectionFeed: UICollectionView!
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(Auth.auth().currentUser?.uid == nil) {
            performSegue(withIdentifier: "logout", sender: nil)
        }
    }
    
    func downloadImages() {
        let dbref = Database.database().reference(withPath: "Posts")
        dbref.queryOrdered(byChild: "date").queryLimited(toFirst: 100).observe(.childAdded, with: { (snapshot) in
            let dictionary = snapshot.value as! [String : AnyObject]
            let appendPost = Post()
            appendPost.pathToImage256 = dictionary["pathToImage256"] as? String
            appendPost.likes = dictionary["likes"] as? Int
            self.posts.insert(appendPost, at: 0)
            self.collectionFeed.reloadData()
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
    @IBAction func refreshButtonClicked(_ sender: Any) {
        self.collectionFeed.reloadData()
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "cameraSeg", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageFeedCell
        cell.myImage.downloadImage(from: self.posts[indexPath.row].pathToImage256)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let storleken = CGSize(width: self.view.frame.width/3.1, height: self.view.frame.width/3)
        return storleken
    }
    
}

extension UIImageView {
    func downloadImage(from imgURL: String) {
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, responds, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}









