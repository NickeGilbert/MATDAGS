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
    var users = [User]()
    var search = [SearchCell]()
    var filteredUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.instance().showActivityIndicator()
        //Testa att göra en clear
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
        // cell.pictureOutlet?.image = //För att hämta bild
        return cell
    }
    
    func filterContent(searchText:String)
    {
        filteredUsers = users.filter { $0.alias.lowercased() == searchText.lowercased() }
        searchUsersTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "searchResult", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if(segue.identifier == "searchResult")
        {
            if let rowNumber = sender as? Int {
                print("\n \(rowNumber) \n")
                let searchResult = segue.destination as! ProfileVC
                
                if searchController.isActive && searchController.searchBar.text != "" {
                    searchResult.users = filteredUsers[rowNumber]
                } else {
                    searchResult.users = users[rowNumber]
                }
                searchResult.fromSearch = true
            }
        }
    }
}
