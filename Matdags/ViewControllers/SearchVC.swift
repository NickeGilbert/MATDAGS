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
    var tempUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subview.isHidden = true
        self.subviewBackground.isHidden = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
      //  searchUsersTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        searchUsersTableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //subviewCell.removeAll()
        posts.removeAll()
        users.removeAll()
        search.removeAll()
        filteredUsers.removeAll()
        getUserInfo(in: dispatchGroup) { (true) in
        self.searchUsersTableView.reloadData()
        }
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
        let uid = Auth.auth().currentUser!.uid
        let db = Database.database()
        let dbref = db.reference(withPath: "Users/\(uid)/Following")
        //let uref = db.reference(withPath: "Users/\(uid)")
        let followingUID = subviewCell.userID
        let followingAlias = subviewCell.alias
        if subviewCell.userID != nil {
            let following = ["\(followingAlias!)" : followingUID!] as [String : Any]
            //let counter = ["followingCounter" : +1] as [String : Any]
            //uref.updateChildValues(counter)
            dbref.updateChildValues(following)
        } else {
            print("\n userID not found when adding follower \n")
        }
    }
    
    func getFollower() {
        let db = Database.database()
        let uid = Auth.auth().currentUser!.uid
        let alias = Auth.auth().currentUser!.displayName
        let followerUID = subviewCell.userID
        let dbref = db.reference(withPath: "Users/\(followerUID!)/Follower")
        //let uref = db.reference(withPath: "Users/\(uid)")
        if subviewCell.userID != nil {
            let follower = ["\(alias!)" : "\(uid)" ] as [String : Any]
            //let counter = ["followerCounter" : +1 ] as [String : Any]
            //uref.updateChildValues(counter)
            dbref.updateChildValues(follower)
        } else {
            print("\n userID not found when getting follower \n")
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
        return filteredUsers.count
        } else {
        return self.users.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userInfo = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        cell.usernameLabel.text = userInfo.alias
        if self.users[indexPath.row].profileImageURL != "" {
            cell.pictureOutlet.downloadImage(from: self.users[indexPath.row].profileImageURL)
            
        } else if (FBSDKAccessToken.current() != nil) {
            cell.pictureOutlet.downloadImage(from: "http://graph.facebook.com/"+FBSDKAccessToken.current().userID+"/picture?type=large")
        }else {
            print("Do nothing")
            //Här kan vi sätta en default bild om användaren inte har laddat upp profilbild
            //print("\n \(indexPath.row) could not return a value for profileImageURL from User. \n")
        }
        if searchController.isActive && searchController.searchBar.text != "" {
            tempUser = filteredUsers[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        downloadImages()
        tempUser = self.users[indexPath.row]
        self.subview.isHidden = false
        self.subviewBackground.isHidden = false
        self.subviewUsername.text = tempUser.alias
        let cell = searchUsersTableView.cellForRow(at: indexPath) as! SearchCell
        if tempUser.profileImageURL != "" {
            self.subviewProfileImage.image = cell.pictureOutlet.image
        } else {
            //Här kan vi bestämma default bild för subviewn
            self.subviewProfileImage.image = nil
            
            if (FBSDKAccessToken.current() != nil) {
                self.subviewProfileImage.downloadImage(from: "http://graph.facebook.com/"+FBSDKAccessToken.current().userID+"/picture?type=large")
            }else {
                print("Do nothing")
                //Här kan vi sätta en default bild om användaren inte har laddat upp profilbild
                print("\n \(indexPath.row) could not return a value for profileImageURL from User. \n")
            }
        }
        if self.tempUser.uid != Auth.auth().currentUser!.uid {
            self.subviewFollowButton.isHidden = false
        } else {
            self.subviewFollowButton.isHidden = true
        }
        subviewCell.userID = tempUser.uid
        subviewCell.alias = tempUser.alias
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
    
    func filterContent(searchText:String) {
        filteredUsers = self.users.filter { user in
        return(user.alias.lowercased() == searchText.lowercased())
        }
    }
    
    ///////////////////////////////////SUBVIEW///////////////////////////////////////////////////////
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subviewCell", for: indexPath) as! SearchSubViewCell
        cell.mySubviewCollectionFeed.image = nil
        if self.posts[indexPath.row].pathToImage256 != nil {
            cell.mySubviewCollectionFeed.downloadImage(from: self.posts[indexPath.row].pathToImage256)
        } else {
            //print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width/4.0, height: self.view.frame.width/4.0)
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

    func downloadImages() {
        let uid = Auth.auth().currentUser!.uid
        let dbref = Database.database().reference(withPath: "Users").child("\(uid)/Posts")
        dbref.queryLimited(toFirst: 100).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                for (_, post) in dictionary {
                    let appendPost = Post()
                    appendPost.pathToImage256 = post["pathToImage256"] as? String
                    appendPost.postID = post["postID"] as? String
                    self.posts.insert(appendPost, at: 0)
                }
            }
            self.subviewCollectionFeed.reloadData()
        })
    }
}
