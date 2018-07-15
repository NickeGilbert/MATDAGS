//  ImageFeedVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-09-15.
//  Copyright © 2017 Nicklas Gilbertson. All rights reserved.

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit

class ImageFeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UITabBarControllerDelegate {

    @IBOutlet var collectionFeed: UICollectionView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var settingsOverlayView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var settingsViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsViewInner: UIView!
    @IBOutlet weak var settingsViewCloseButton: UIButton!
    
    let dispatchGroup = DispatchGroup()
    var posts = [Post]()
    var refresher : UIRefreshControl!
    var cellCounter : Int = 0
    var cellCounter2 : Int = 0
    var vegiBool = false
    var postsDuplicateArray = [Post]()
    var myBlockedUsers = [String]()
    var usersThatBlockedMe = [String]()
    let db = Database.database()
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutButton.setTitle(NSLocalizedString("logoutButton", comment: ""), for: .normal)
        refresher = UIRefreshControl()
        collectionFeed!.alwaysBounceVertical = true
        refresher.tintColor = UIColor.lightGray
        refresher.attributedTitle = NSAttributedString(string: "Hello")
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        collectionFeed!.addSubview(refresher)
        settingsOverlayView.isHidden = true
        settingsView.layer.cornerRadius = 5
        
        let tapRecognizerSettings = UITapGestureRecognizer(target: self, action: #selector(self.onSelect(_:)))
        tapRecognizerSettings.delegate = self
        
        settingsOverlayView?.addGestureRecognizer(tapRecognizerSettings)
        settingsViewTopConstraint.constant = view.bounds.size.height
        settingsViewInner.layer.cornerRadius = 10
        settingsViewInner.clipsToBounds = true
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(uid == nil) {
            performSegue(withIdentifier: "logout", sender: nil)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    @IBAction func openSettingsAction(_ sender: Any) {
        tabBarController?.tabBar.isHidden = true
        let animations = {
            self.settingsViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        let completion = { (finished: Bool) in
            self.settingsViewCloseButton.backgroundColor = UIColor.black
            self.settingsViewCloseButton.alpha = 0.1
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.2,
                       animations: animations,
                       completion: completion)
    }
    @IBAction func closeSettingsAction(_ sender: Any) {
        self.settingsViewCloseButton.backgroundColor = UIColor.clear
        self.settingsViewCloseButton.alpha = 0
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
            self.settingsViewTopConstraint.constant = self.view.bounds.size.height
            self.tabBarController?.tabBar.isHidden = false
            self.view.layoutIfNeeded()
        })
    }

    @IBAction func vegiAction(_ sender: Any) {
        vegiClickfunction()
    }
    
    
    @IBAction func logOutAction(_ sender: Any) {
        logOutFunction()
    }
    
    func vegiClickfunction() {
        if vegiBool == false {
            vegiClickImage.image = UIImage(named: "vegButton50SettingsFinal")
            loadViewIfNeeded()
            vegiBool = true
            postsDuplicateArray = posts
            posts = posts.filter { ($0.vegi == true) }
            collectionFeed.reloadData()
        } else {
            vegiClickImage.image = UIImage(named: "vegButtonUseSettings2Final")
            vegiBool = false
            posts = postsDuplicateArray
            collectionFeed.reloadData()
        }
    }
    
    func logOutFunction() {
        let alert = UIAlertController(title: NSLocalizedString("logoutTitle", comment: ""),
                                      message: NSLocalizedString("logoutMessage", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("logOut", comment: ""),
                                      style: .destructive,
                                      handler: { action in
                                        do {
                                            try Auth.auth().signOut()
                                            let loginManager = FBSDKLoginManager()
                                            loginManager.logOut()
                                            self.performSegue(withIdentifier: "logout", sender: nil)
                                        } catch {
                                            print("\nCould not log out succesfully.\n")
                                        }
        }))
        
        alert.addAction(UIAlertAction(title: "Stäng", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func onSelect(_ sender: Any) {
        settingsOverlayView.isHidden = true
    }
    
    @objc func loadData() {
        //För att undvika problem bör vi begränsa så man inte kan reloada hur ofta som helst.
        self.posts.removeAll()
        getMyBlockedUsers()
        cellCounter = 0
        cellCounter2 = 0
        downloadImages { (true) in
            self.posts.sort(by: {$0.timestamp > $1.timestamp})
            self.collectionFeed.reloadData()
            self.refresher.endRefreshing()
        }
    }
    
    func downloadImages(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        let dbref = Database.database().reference(withPath: "Posts")
        //ToDo: Begränsa queryn till maxantal posts
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                for (_, post) in dictionary {
                    let filteredID = post["userID"] as? String ?? ""
                    if !self.myBlockedUsers.contains(filteredID) {
                        let appendPost = Post()
                        appendPost.date = post["date"] as? String ?? ""
                        appendPost.pathToImage256 = post["pathToImage256"] as? String ?? ""
                        appendPost.postID = post["postID"] as? String ?? ""
                        appendPost.vegi = post["vegetarian"] as? Bool ?? false
                        appendPost.timestamp = post["timestamp"] as? String ?? ""
                        self.posts.append(appendPost)
                    }
                }
            }
            completionHandler(true)
        })
    }
    
    @IBOutlet weak var vegiClickImage: UIImageView!
    @IBOutlet weak var vegiClickButton: UIButton!
    
    @IBAction func vegiClick(_ sender: Any) {
        if vegiBool == false {
            vegiClickImage.image = UIImage(named: "vegButton50SettingsFinal")
            loadViewIfNeeded()
            vegiBool = true
            postsDuplicateArray = posts
            posts = posts.filter { ($0.vegi == true) }
            collectionFeed.reloadData()
        } else {
            vegiClickImage.image = UIImage(named: "vegButtonUseSettings2Final")
            vegiBool = false
            posts = postsDuplicateArray
            collectionFeed.reloadData()
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("logoutTitle", comment: ""),
                                      message: NSLocalizedString("logoutMessage", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("logOut", comment: ""),
                                      style: .destructive,
                                      handler: { action in
            do {
                try Auth.auth().signOut()
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                self.performSegue(withIdentifier: "logout", sender: nil)
            } catch {
                print("\nCould not log out succesfully.\n")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Stäng", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func camerButtonTouch(_ sender: Any) {
        performSegue(withIdentifier: NSLocalizedString("closeTitle", comment: ""), sender: nil)
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
        
        if !self.posts.isEmpty {
            if self.posts[indexPath.row].vegi != false {
                cell.vegiIcon.isHidden = false
            } else {
                cell.vegiIcon.isHidden = true
            }
            
            if self.posts[indexPath.row].pathToImage256 != nil {
                cell.myImage.downloadImage(from: self.posts[indexPath.row].pathToImage256)
            } else {
                print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
            }
            cachedImages?.sd_setImage(with: URL(string: self.posts[indexPath.row].pathToImage256))
        } else {
            print("\(indexPath.row) could not reload properly.")
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var storleken = CGSize()

//        let n = Int(arc4random_uniform(2))
//        let onePart = self.view.frame.width / 3.2
//        let twoPart = onePart + onePart + 8
//        let topCounter = Int(arc4random_uniform(2))
//
//        func left() {
//            if cellCounter == 3 { // fungerande från vänster
//                if n == 0 {
//                    storleken = CGSize(width: self.view.frame.width/3.2, height: self.view.frame.width/3.2)
//                    cellCounter = 1
//                    cellCounter2 = 2
//                } else {
//                    storleken = CGSize(width: twoPart, height: self.view.frame.width/3.2)
//                    cellCounter = -1
//                    cellCounter2 = 0
//                }
//
//            }else{
//                storleken = CGSize(width: self.view.frame.width/3.2, height: self.view.frame.width/3.2)
//                cellCounter += 1
//                cellCounter2 += 1
//            }
//        }
//
//        func right(){
//            if cellCounter2 == 4 { // fungerande från höger
//                if n == 0 {
//                    storleken = CGSize(width: self.view.frame.width/3.2, height: self.view.frame.width/3.2)
//                    cellCounter2 = 2
//                    cellCounter = 1
//                } else {
//                    storleken = CGSize(width: twoPart, height: self.view.frame.width/3.2)
//                    cellCounter2 = 0
//                    cellCounter = -1
//                }
//
//            }else{
//                storleken = CGSize(width: self.view.frame.width/3.2, height: self.view.frame.width/3.2)
//                cellCounter2 += 1
//                cellCounter += 1
//            }
//        }
//
//        if topCounter == 0 {
//            left()
//        }else{
//            right()
//        }
        
        //print("Cellcounter 1 : ", cellCounter)
        //print("CellCounter 2 : ", cellCounter2)
        //print("---------------")
        
        
        storleken = CGSize(width: self.view.frame.width/3.2, height: self.view.frame.width/3.2)
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
