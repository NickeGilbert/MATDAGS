//  FollowersCell.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-10-19.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit

class FollowersCell: UICollectionViewCell {
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var imageFeedView: UIImageView!    
    @IBOutlet var starButtons: [UIButton]!
    
    var starHighlited = 0
    
    @IBAction func starButtonsTapped(_ sender: UIButton) {
        starHighlited = sender.tag + 1
        print(starHighlited)
        
        for button in starButtons {
            button.setTitle("☆", for: .normal)
            
            if button.tag <= starHighlited-1 {
                button.setTitle("⭐️", for: .normal)
            }
        }
    }
    
    func resizeImage(){
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
        self.profileImage.layer.borderColor = UIColor.white.cgColor
        self.profileImage.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
        self.profileImage.layer.borderColor = UIColor.white.cgColor
        self.profileImage.layer.borderWidth = 2
    }
}
