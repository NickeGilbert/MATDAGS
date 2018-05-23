//  SearchVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-11-08.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class SearchVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var subviewUnfollowBtn: UIButton!
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var subviewUsername: UILabel!
    @IBOutlet weak var subviewProfileImage: UIImageView!
    @IBOutlet weak var subviewCollectionFeed: UICollectionView!
    @IBOutlet var searchUsersTableView: UITableView!
    @IBOutlet weak var subviewFollowButton: UIButton!
    
    let searchController = UISearchController(searchResultsController: nil)
    let dispatchGroup = DispatchGroup()
    
    //Database stuff
    let db = Database.database()
    let uid = Auth.auth().currentUser?.uid
    
    var posts = [Post]()
    var users = [User]()
    var count : Int = 0
    var countFollower : Int = 0
    var userId = ""
    var userFollowing = [String]()
    var initialFeed = [String]()
    var isSearching = false
    var searchRef = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.becomeFirstResponder()
        //DB Refs
        searchRef = searchRef.child("Users")
        
        //Get Data
        getUserFollowing()
        
        //TableView
        searchUsersTableView.delegate = self
        searchUsersTableView.dataSource = self
        searchUsersTableView.separatorStyle = .none
        searchUsersTableView.tableHeaderView = searchController.searchBar
        
        //SubView
        subview.isHidden = true
//        subview.layer.cornerRadius = 2
        subview.layer.cornerRadius = 20
        subview.clipsToBounds = true
        subviewUnfollowBtn.backgroundColor = followUser
        subviewFollowButton.backgroundColor = unfollowUser
        subviewFollowButton.layer.cornerRadius = 5
        
        //SearchController
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.searchBar.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.becomeFirstResponder()
    }
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        tabBarController?.selectedIndex = 2
    }

    func getUserFollowing() {
        //Används för subviewn om man följer eller inte följer användaren
        let dbref = db.reference().child("Users/\(uid)/Following")
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let tempSnapshot = snapshot.value as? [String : AnyObject] {
                for (_, each) in tempSnapshot {
                    let appendUser = User()
                    appendUser.uid = each["uid"] as? String
                    self.userFollowing.append(each as! String)
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        if !users.isEmpty {
            let username = users[indexPath.row]
            
            cell.pictureOutlet.image = defaultProfileImage
            cell.usernameLabel.text = username.alias
            
            let imageURL = username.profileImageURL
            
            if username.profileImageURL != nil && username.profileImageURL != "" {
                cell.pictureOutlet.downloadImage(from: imageURL!)
            } else {
                cell.pictureOutlet.image = defaultProfileImage
            }
            
        } else {
            self.searchUsersTableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchController.searchBar.endEditing(true)
        guard let cell = searchUsersTableView.cellForRow(at: indexPath) as? SearchCell else { return }
        let username = users[indexPath.row]
        let userID = username.uid
        
        downloadImages(uid: username.uid)
        
        self.userId = users[indexPath.row].uid
        self.subview.isHidden = false
        self.subviewUsername.text = username.alias
        self.subviewFollowButton.isHidden = false
        self.subviewUnfollowBtn.isHidden = true

        if uid == userID {
            self.subviewFollowButton.isHidden = true
            self.subviewUnfollowBtn.isHidden = true
        }
            for user in userFollowing {
                if userId == user {
                    print("\nYou are following this user.")
                    self.subviewFollowButton.isHidden = true
                    self.subviewUnfollowBtn.isHidden = false
                } else {
                    print("\nYou are not following this user.")
                    self.subviewFollowButton.isHidden = false
                    self.subviewUnfollowBtn.isHidden = true
                }
        }
        
        if username.profileImageURL != "" {
            self.subviewProfileImage.image = cell.pictureOutlet.image
        } else {
            self.subviewProfileImage.image = defaultProfileImage
        }
    }
    
    func searchForUser() {
        let inputText = searchController.searchBar.text
        searchRef.queryOrdered(byChild: "alias").queryStarting(atValue: inputText).queryEnding(atValue: inputText! + "\u{f8ff}", childKey: "alias").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                for (_, each) in dictionary {
                    let appendUser = User()
                    appendUser.alias = each["alias"] as? String
                    appendUser.uid = each["uid"] as? String
                    appendUser.profileImageURL = each["profileImageURL"] as? String
                    print("\n\(appendUser.alias!) \n\(appendUser.uid!) \n\(appendUser.profileImageURL!)\n")
                    self.users.append(appendUser)
                    self.searchUsersTableView.insertRows(at: [IndexPath(row: self.users.count-1, section: 0)], with: .none)
                }
            }
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        users = []
        searchBar.text = ""
        searchUsersTableView.reloadData()
        self.subview.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchUsersTableView.reloadData()
        searchBar.endEditing(true)
    }
    
    func filterUsers() {
        if isSearching {
            searchRef.removeAllObservers()
            searchForUser()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            users = []
            self.subview.isHidden = true
            searchUsersTableView.reloadData()
            
        } else {
            isSearching = true
            users = []
            self.subview.isHidden = true
            searchUsersTableView.reloadData()
            
            filterUsers()
        }
    }
}
