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
    
    var posts = [Post]()
    var users = [User]()
    var filteredUsers = [User]()
    var count : Int = 0
    var countFollower : Int = 0
    var userId = ""
    var userFollowing = [String]()
    var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get Data
        getUserFollowing()
        getUserInfo(in: dispatchGroup) { (true) in
            self.searchUsersTableView.reloadData()
        }
        
        //TableView
        searchUsersTableView.delegate = self
        searchUsersTableView.dataSource = self
        searchUsersTableView.separatorStyle = .none
        searchUsersTableView.tableHeaderView = searchController.searchBar
        
        //SubView
        subview.isHidden = true
        subview.layer.cornerRadius = 3
        subview.clipsToBounds = true
        subviewUnfollowBtn.backgroundColor = followUser
        subviewFollowButton.backgroundColor = unfollowUser
        
        //SearchController
        //searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        tabBarController?.selectedIndex = 2
    }

    func getUserFollowing() {
        let uid = Auth.auth().currentUser!.uid
        let dbref = Database.database().reference().child("Users/\(uid)/Following")
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
    
    func getUserInfo(in dispatchGroup: DispatchGroup, completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        AppDelegate.instance().showActivityIndicator()
        let dbref = Database.database().reference(withPath: "Users")
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                dispatchGroup.enter()
                for (_, each) in dictionary {
                    let appendUser = User()
                    appendUser.alias = each["alias"] as? String
                    appendUser.uid = each["uid"] as? String
                    appendUser.profileImageURL = each["profileImageURL"] as? String
                    print("\n\(appendUser.alias!) \n\(appendUser.uid!) \n\(appendUser.profileImageURL!)\n")
                    self.users.append(appendUser)
                    self.searchUsersTableView.insertRows(at: [IndexPath(row:self.users.count-1,section:0)], with: UITableViewRowAnimation.automatic)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredUsers.count : users.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        let username = searchController.isActive ? filteredUsers[indexPath.row] : users[indexPath.row]
        
        cell.pictureOutlet.image = defaultProfileImage
        cell.usernameLabel.text = username.alias
        
        let imageURL = username.profileImageURL
        
        if username.profileImageURL != nil && username.profileImageURL != "" {
            cell.pictureOutlet.downloadImage(from: imageURL!)
        } else {
            cell.pictureOutlet.image = defaultProfileImage
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = searchUsersTableView.cellForRow(at: indexPath) as? SearchCell else { return }
        let username = searchController.isActive ? filteredUsers[indexPath.row] : users[indexPath.row]
        let uid = Auth.auth().currentUser!.uid
        let userID = username.uid
        
        downloadImages(uid: userID!)

        self.subview.isHidden = false
        self.subviewUsername.text = username.alias
        self.subviewFollowButton.isHidden = true
        self.subviewUnfollowBtn.isHidden = true
        
        
        if uid == userID {
            self.subviewFollowButton.isHidden = true
            self.subviewUnfollowBtn.isHidden = true
        } else if uid != userID {
            for user in userFollowing {
                if userID == user {
                    print("\nYou are following this user.")
                    self.subviewFollowButton.isHidden = true
                    self.subviewUnfollowBtn.isHidden = false
                    break
                } else {
                    print("\nYou are not following this user.")
                    self.subviewFollowButton.isHidden = false
                    self.subviewUnfollowBtn.isHidden = true
                    break
                }
            }
        }
        
        if username.profileImageURL != "" {
            self.subviewProfileImage.image = cell.pictureOutlet.image
        } else {
            self.subviewProfileImage.image = defaultProfileImage
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        filterUsers { (true) in
            self.searchUsersTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchUsersTableView.reloadData()
    }
    
    func filterUsers(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        let searchText = searchController.searchBar.text ?? ""
        filteredUsers = self.users.filter {
            user in
            let username = user.alias.lowercased().contains(searchText.lowercased()) || searchText.lowercased().count == 0
            return username
        }
        completionHandler(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != nil || searchBar.text != "" {
            isSearching = true
            
            filteredUsers = []
            
            filterUsers(completionHandler: { (true) in
                self.searchUsersTableView.reloadData()
            })
            
        } else {
            isSearching = false
            
            searchUsersTableView.reloadData()
        }
    }
}
