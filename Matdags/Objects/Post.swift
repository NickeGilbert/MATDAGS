//  Post.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-11-04.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit

class Post: NSObject {
    var postID : String!
    var pathToImage : String!
    var pathToImage256 : String!
    var rating : Double!
    var userID : String!
    var imgdescription : String!
    var alias : String!
    var vegi : Bool?
    var comments : [String]!
    var usersRated : Double!
}
