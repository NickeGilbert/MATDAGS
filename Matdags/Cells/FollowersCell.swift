//  FollowersCell.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-10-19.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit

class FollowersCell: UICollectionViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    //@IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var imageFeedView: UIImageView!
    @IBOutlet weak var vegiIcon: UIImageView!
    @IBOutlet var starButtonArray: [UIButton]!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var CellBottomView: UIView!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    @IBOutlet weak var mySubviewCollectionFeed: UIImageView!
    
    
    
   
    //var posts = [Post]()
    //var users = [User]()

   /* func resizeImage(){
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
        self.profileImage.layer.borderColor = UIColor.white.cgColor
        self.profileImage.layer.borderWidth = 2
    }*/
    
    /*override func layoutSubviews() {
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
        self.profileImage.layer.borderColor = UIColor.white.cgColor
        self.profileImage.layer.borderWidth = 2
    }*/
}
