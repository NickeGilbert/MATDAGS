//  SearchVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-11-08.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseDatabase

class SearchVC: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet var searchUsersTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var posts = [Post]()
    var search = [SearchCell]()
    var usersArray = [NSDictionary?]()
    var filteredUsers = [NSDictionary?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.instance().showActivityIndicator()
        //Testa att göra en clear
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchUsersTableView.tableHeaderView = searchController.searchBar

        let dbref = Database.database().reference(withPath: "Users")
        dbref.queryOrdered(byChild: "alias").observe(.childAdded, with: { (snapshot) in
            
            self.usersArray.append(snapshot.value as? NSDictionary) //Måste fixas så inte användarna syns från början! Eller är det, det vi vill ha?
            
            self.searchUsersTableView.insertRows(at: [IndexPath(row:self.usersArray.count-1,section:0)], with: UITableViewRowAnimation.automatic)
            AppDelegate.instance().dismissActivityIndicator()
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
        return  filteredUsers.count
        }
        return self.usersArray.count //Ska visas max 10-20 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchCell
        
        let user : NSDictionary?
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = self.usersArray[indexPath.row]
        }
        cell.usernameLabel?.text = user?["alias"] as? String
        //cell.pictureOutlet.image = self.usersArray[indexPath.item]?["postID"] as? UIImage //För att hämta bild
        return cell
    }
    
    func filterContent(searchText:String)
    {
        self.filteredUsers = self.usersArray.filter{ user in
            let username = user!["alias"] as? String
            return(username?.lowercased().contains(searchText.lowercased()))!
        }
        searchUsersTableView.reloadData()
    }
}
