//  SearchCell.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-11-09.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit

class SearchCell: UITableViewCell {
    
    @IBOutlet var pictureOutlet: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resizeImage()
    }
    override func prepareForReuse() {
        pictureOutlet.image = nil
        usernameLabel.text = nil
    }
    func resizeImage(){
        pictureOutlet.layer.cornerRadius = pictureOutlet.frame.size.height / 2
        pictureOutlet.clipsToBounds = true
        self.pictureOutlet.layer.borderColor = UIColor.white.cgColor
        self.pictureOutlet.layer.borderWidth = 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
