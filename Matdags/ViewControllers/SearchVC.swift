//  SearchVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-11-08.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class SearchVC: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var subviewUnfollowBtn: UIButton!
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var subviewUsername: UILabel!
    @IBOutlet weak var subviewProfileImage: UIImageView!
    @IBOutlet weak var subviewCollectionFeed: UICollectionView!
    @IBOutlet var searchUsersTableView: UITableView!
    @IBOutlet weak var subviewFollowButton: UIButton!
    
    let searchController = UISearchController(searchResultsController: nil)
    let dispatchGroup = DispatchGroup()
    
    var ref: DatabaseReference!
    var subviewCell = SearchSubViewCell()
    var posts = [Post]()
    var users = [User]()
    var search = [SearchCell]()
    var filteredUsers = [User]()
    var username = User()
    var count : Int = 0
    var countFollower : Int = 0
    var userId = ""
    var yourFollowers = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.subviewUnfollowBtn.isHidden = true
        getUserUID()
        self.subview.isHidden = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchUsersTableView.tableHeaderView = searchController.searchBar
        getUserInfo(in: dispatchGroup) { (true) in
            self.searchUsersTableView.reloadData()
            
        }
        subview.layer.cornerRadius = 3
        subview.clipsToBounds = true
        
        subviewUnfollowBtn.backgroundColor = followUser
        subviewFollowButton.backgroundColor = unfollowUser
        
    }
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        tabBarController?.selectedIndex = 2
    }

    func getUserUID() {
        let uid = Auth.auth().currentUser!.uid
        let dbref = Database.database().reference().child("Users/\(uid)/Following")
        dbref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let tempSnapshot = snapshot.value as? [String : AnyObject] {
                for (_, each) in tempSnapshot {
                    let appendUser = User()
                    appendUser.uid = each["uid"] as? String
                    print("\(each) ANVÄNDARNAS UID ")
                    self.yourFollowers.append(each as! String)
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
                    print("\n \(appendUser.alias) \n \(appendUser.uid) /n \(appendUser.profileImageURL)")
                    self.users.append(appendUser)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredUsers.count : users.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        let username = searchController.isActive ? filteredUsers[indexPath.row] : users[indexPath.row]
        
        cell.usernameLabel.text = username.alias
        
        if self.users[indexPath.row].profileImageURL != "" {
            cell.pictureOutlet.downloadImage(from: self.users[indexPath.row].profileImageURL)
        } else {
            cell.pictureOutlet.image = #imageLiteral(resourceName: "profileImagePlaceholder")
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = searchUsersTableView.cellForRow(at: indexPath) as? SearchCell else { return }
        let username = searchController.isActive ? filteredUsers[indexPath.row] : users[indexPath.row]
        
        downloadImages(uid: username.uid)

        self.userId = users[indexPath.row].uid
        self.subview.isHidden = false
        self.subviewUsername.text = username.alias
        self.subviewFollowButton.isHidden = false
        self.subviewUnfollowBtn.isHidden = true
        
        for user in yourFollowers {
            if userId == user {
                self.subviewFollowButton.isHidden = true
                self.subviewUnfollowBtn.isHidden = false
            } else if userId == Auth.auth().currentUser?.uid {
                self.subviewFollowButton.isHidden = true
                self.subviewUnfollowBtn.isHidden = true
            }
        }
        
        if username.profileImageURL != "" {
            self.subviewProfileImage.image = cell.pictureOutlet.image
        } else {
            self.subviewProfileImage.image = nil
        }
    }
    
    func insertRow() {
        self.searchUsersTableView.insertRows(at: [IndexPath(row:self.users.count-1,section:0)], with: UITableViewRowAnimation.automatic)
    }
    
    func filterContent(searchText:String) {
        let searchText = self.searchController.searchBar.text ?? ""
        filteredUsers = self.users.filter { user in

            let username = user.alias.lowercased().contains(searchText.lowercased()) || searchText.lowercased().characters.count == 0            
            return username
        }
       
        searchUsersTableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(searchText: searchController.searchBar.text!)
        print(userId)
    }
}
