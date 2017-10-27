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
    
    var feedArray = [Images]()
    let cellIdentifier = "cell"
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return feedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! FollowersCVCell
        
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        }
}
