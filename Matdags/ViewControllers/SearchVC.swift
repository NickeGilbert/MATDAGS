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
   
    let searchController = UISearchController(searchResultsController: nil)
    
    var subviewCell = [SearchSubViewCell]()
    var posts = [Post]()
    var users = [User]()
    var search = [SearchCell]()
    var filteredUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.instance().showActivityIndicator()
        //Testa att göra en clear
        resizeImage()
        self.subview.isHidden = true
        self.subviewBackground.isHidden = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchUsersTableView.tableHeaderView = searchController.searchBar

        let dbref = Database.database().reference(withPath: "Users")
        dbref.queryLimited(toFirst: 20).observe(.childAdded, with: { (snapshot) in
            let tempUser = User()
            guard let tempSnapshot = snapshot.value as? NSDictionary else { return }
            
            tempUser.alias = tempSnapshot["alias"] as? String
            self.users.append(tempUser)
            self.searchUsersTableView.insertRows(at: [IndexPath(row:self.users.count-1,section:0)], with: UITableViewRowAnimation.automatic)
            
            AppDelegate.instance().dismissActivityIndicator()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        posts.removeAll()
        downloadImages()
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
        return filteredUsers.count
        }
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchCell
        
        var tempUser = User()
        
        if searchController.isActive && searchController.searchBar.text != "" {
            tempUser = filteredUsers[indexPath.row]
        } else {
            tempUser = self.users[indexPath.row]
        }
         cell.usernameLabel?.text = tempUser.alias
         cell.pictureOutlet?.image = tempUser.profilePictureURL as? UIImage//Varför fungerar den inte? Testa att göra en Dispatch
        return cell
    }
    
    func filterContent(searchText:String)
    {
        filteredUsers = users.filter { $0.alias.lowercased() == searchText.lowercased() }
        searchUsersTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.subview.isHidden = false
         self.subviewBackground.isHidden = false

        var tempUser = User()
        tempUser = self.users[indexPath.row]
        
        self.subviewUsername?.text = tempUser.alias
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.posts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subviewCell", for: indexPath) as! SearchSubViewCell
        cell.mySubviewCollectionFeed.image = nil
        cell.backgroundColor = .red
        if self.posts[indexPath.row].pathToImage256 != nil {
            cell.mySubviewCollectionFeed.downloadImage(from: self.posts[indexPath.row].pathToImage256)
        } else {
            print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width/4.0, height: self.view.frame.width/4.0)
        return size
    }

    func downloadImages() {
        let dbref = Database.database().reference(withPath: "Users").child((Auth.auth().currentUser?.uid)!).child("Posts")
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
    
    func resizeImage(){
        subviewProfileImage.layer.cornerRadius = subviewProfileImage.frame.size.height / 2
        subviewProfileImage.clipsToBounds = true
        self.subviewProfileImage.layer.borderColor = UIColor.white.cgColor
        self.subviewProfileImage.layer.borderWidth = 4
    }
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        print("SWIPE SWIPE!!")
        tabBarController?.selectedIndex = 2
    }
    
    @IBAction func closeSubview(_ sender: Any) {
        subview.isHidden = true
         self.subviewBackground.isHidden = true
    }
    @IBAction func subviewFollowUser(_ sender: Any) {
        addfollower()
        getfollower()
    }
    
    func addfollower() { //MÅSTE SKRIVAS OM FÖR ATT ANPASSAS!!!
        //Du följer en användare
       /* let uid = Auth.auth().currentUser!.uid
        let dbref = Database.database().reference().child("Users").child("\(uid)").child("Following")
        
        if self.posts[0] != nil {
            let following = ["\(self.posts[0].alias!)" : self.posts[0].userID!] as [String : Any]
            dbref.updateChildValues(following)
        } else {
            print("HÄMTAR INGENTING")
        }*/
    }
    
    func getfollower() { //MÅSTE SKRIVAS OM FÖR ATT ANPASSAS!!!
        //Användaren får att du följer honom
       /* let uid = Auth.auth().currentUser!.uid
        let alias = Auth.auth().currentUser!.displayName
        let dbref = Database.database().reference().child("Users").child("\(posts[0].userID!)").child("Follower")
        
        let follower = ["\(alias!)" : "\(uid)" ] as [String : Any]
        dbref.updateChildValues(follower)*/
        
    }
    
    
    
    
    
    
    
    
    /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     if(tabBarController?.selectedIndex == "searchResult")
     {
     if let rowNumber = sender as? Int {
     print("\n \(rowNumber) \n")
     let searchResult = tabBarController?.selectedIndex as! ProfileVC
     
     if searchController.isActive && searchController.searchBar.text != "" {
     searchResult.users = filteredUsers[rowNumber]
     } else {
     searchResult.users = users[rowNumber]
     }
     searchResult.fromSearch = true
     }
     }
     }*/
    
}
