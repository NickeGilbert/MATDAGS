//  Images.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-10-25.
//  Copyright © 2017 Matdags. All rights reserved.

import Foundation

class Images {
    
    var fbKey = ""
    var username: String
    var profilePic: String
    var postImage: String
    
    init(profilePic: String, username: String, postImage: String) {
        self.profilePic = profilePic
        self.username = username
        self.postImage = postImage
    }
    
}
