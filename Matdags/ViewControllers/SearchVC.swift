//  SearchVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-11-08.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class SearchVC: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var subviewBackground: UIView!
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var subviewUsername: UILabel!
    @IBOutlet weak var subviewProfileImage: UIImageView!
    @IBOutlet weak var subviewCollectionFeed: UICollectionView!
    @IBOutlet var searchUsersTableView: UITableView!
    @IBOutlet weak var subviewFollowButton: UIButton!
    
    let searchController = UISearchController(searchResultsController: nil)
    let dispatchGroup = DispatchGroup()
    
    var subviewCell = SearchSubViewCell()
    var posts = [Post]()
    var users = [User]()
    var search = [SearchCell]()
    var filteredUsers = [User]()
    var username = User()
    var count : Int = 0
    var countFollower : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subview.isHidden = true
        self.subviewBackground.isHidden = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchUsersTableView.tableHeaderView = searchController.searchBar
        getUserInfo(in: dispatchGroup) { (true) in
            self.searchUsersTableView.reloadData()
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //subviewCell.removeAll()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("BAJS")
    }
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        tabBarController?.selectedIndex = 2
    }
    
    @IBAction func closeSubview(_ sender: Any) {
        subview.isHidden = true
        self.subviewBackground.isHidden = true
        self.subviewProfileImage.image = nil
        self.subviewUsername.text = nil
    }
    
    @IBAction func subviewFollowUser(_ sender: Any) {
        addFollower()
        getFollower()
    }
    
    func addFollower() {
        //ToDo: Fungerande counter
        let db = Database.database()
        let uid = Auth.auth().currentUser!.uid
        let alias = Auth.auth().currentUser!.displayName
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
        let db = Database.database()
        let uid = Auth.auth().currentUser!.uid
        let alias = Auth.auth().currentUser!.displayName
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
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(searchText: searchController.searchBar.text!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredUsers.count : users.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // let userInfo = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        let username = searchController.isActive ? filteredUsers[indexPath.row] : users[indexPath.row]
        
        cell.usernameLabel.text = username.alias
        if self.users[indexPath.row].profileImageURL != "" {
            cell.pictureOutlet.downloadImage(from: self.users[indexPath.row].profileImageURL)
        
        } else {
            print("Do nothing")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var username = searchController.isActive ? filteredUsers[indexPath.row] : users[indexPath.row]
        downloadImages(uid: username.uid)
        // username = self.users[indexPath.row]
        self.subview.isHidden = false
        self.subviewBackground.isHidden = false
        self.subviewUsername.text = username.alias
        let cell = searchUsersTableView.cellForRow(at: indexPath) as! SearchCell
        if username.profileImageURL != "" {
            self.subviewProfileImage.image = cell.pictureOutlet.image
        } else {
            self.subviewProfileImage.image = nil
        }
        //Verkar inte göra något än!
        if self.username.uid != Auth.auth().currentUser!.uid {
            self.subviewFollowButton.isHidden = false
        } else {
            self.subviewFollowButton.isHidden = true
        }
        subviewCell.userID = username.uid
        subviewCell.alias = username.alias
    }
    
    func getUserInfo(in dispatchGroup: DispatchGroup, completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        AppDelegate.instance().showActivityIndicator()
        users.removeAll()
        let dbref = Database.database().reference(withPath: "Users")
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                dispatchGroup.enter()
                for (_, each) in dictionary {
                    let appendUser = User()
                    appendUser.alias = each["alias"] as? String
                    appendUser.uid = each["uid"] as? String
                    appendUser.profileImageURL = each["profileImageURL"] as? String
                    print("\n \(appendUser.alias) \n \(appendUser.uid) /n \(appendUser.profileImageURL)")
                    self.users.append(appendUser)
                    
                    //VERKAR SOM ATT VI GÖR DUBBELT! KOLLA MED KEVIN! SAMTIDIGT SÅ BLIR RESULTATET RÄTT MED DENNA KODEN
                    self.insertRow()
                }
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main, execute: {
                    print("\n dispatchGroup completed \n")
                    completionHandler(true)
                    AppDelegate.instance().dismissActivityIndicator()
                })
            }
        })
    }
    
    func insertRow() {
        self.searchUsersTableView.insertRows(at: [IndexPath(row:self.users.count-1,section:0)], with: UITableViewRowAnimation.automatic)
    }
    
    func filterContent(searchText:String) {
        let searchText = self.searchController.searchBar.text ?? ""
        filteredUsers = self.users.filter{ user in
            
            let username = user.alias.lowercased().contains(searchText.lowercased()) || searchText.lowercased().characters.count == 0
            return username
        }
        searchUsersTableView.reloadData()
    }
    
    ///////////////////////////////////SUBVIEW///////////////////////////////////////////////////////
    
    func downloadImages(uid: String) {
        posts.removeAll()
        let dbref = Database.database().reference(withPath: "Users/\(uid)/Posts")
        dbref.queryOrderedByKey().queryLimited(toFirst: 100).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                for (_, post) in dictionary {
                    let appendPost = Post()
                    appendPost.pathToImage256 = post["pathToImage256"] as? String
                    appendPost.postID = post["postID"] as? String
                    appendPost.vegi = post["vegetarian"] as? Bool
                    self.posts.insert(appendPost, at: 0)
                }
            }
            self.subviewCollectionFeed.reloadData()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subviewCell", for: indexPath) as! SearchSubViewCell
        cell.mySubviewCollectionFeed.image = nil
        if self.posts[indexPath.row].pathToImage256 != nil {
            cell.mySubviewCollectionFeed.downloadImage(from: self.posts[indexPath.row].pathToImage256)
        } else {
            print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width/3.7, height: self.view.frame.width/4.0)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "imagePageSegSubSearch", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "imagePageSegSubSearch")
        {
            let selectedCell = sender as! NSIndexPath
            let selectedRow = selectedCell.row
            let imagePage = segue.destination as! ImagePageVC
            imagePage.seguePostID = self.posts[selectedRow].postID
        } else {
            print("\n Segue with identifier (imagePage) not found. \n")
        }
    }
}
