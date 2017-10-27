//
//  FollowersVC.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2017-10-17.
//  Copyright © 2017 Matdags. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FollowersVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
   
    
    @IBOutlet var feedCollectionView: UICollectionView!
    
    //var feedArray = [Post]()  Ska läggas in senare
    let 
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let followerscell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: IndexPath) as! FollowersCVCell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        }
}
