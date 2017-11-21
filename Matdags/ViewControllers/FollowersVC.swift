//  FollowersVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-10-17.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseDatabase

class FollowersVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var feedCollectionView: UICollectionView!
    
    var ref: DatabaseReference!
    var feedArray = [FollowersCell]()    
    var posts = [Post]()
    var count:Int! = 0
    var lastCount:Int! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return 10 //Ska vara feedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "followersCell", for: indexPath) as! FollowersCell
        return cell
    }
}
