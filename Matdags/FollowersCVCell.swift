//
//  FollowersCVCell.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2017-10-27.
//  Copyright © 2017 Matdags. All rights reserved.
//

import UIKit

class FollowersCVCell: UICollectionViewCell {
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var postImageView: UIImageView!
    
    
    
    @IBOutlet var starButtons: [UIButton]!
    
    
    @IBAction func starButtonsTapped(_ sender: UIButton) {
        
        let tag = sender.tag
        for button in starButtons {
            if button.tag <= tag {
                button.setTitle("⭐️", for: .normal)
            } else {
                button.setTitle("☆", for: .normal)
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
