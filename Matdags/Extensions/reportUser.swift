//
//  reportUser.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-05-25.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit
import Firebase

var maxReports = 5
var countReports = 0

extension ImagePageVC {
    func reportUser() {
        if countReports == maxReports {
            let ref = Database.database().reference().child("Posts").child(seguePostID)
            ref.removeValue { (error, ref) in
                if error != nil {
                    print("DIDN'T GO THROUGH")
                    return
                }
                self.dismiss(animated: true, completion: nil)
                print("POST DELETED")
            }
            
            //I denna funktionen måste uid bytas ut. Det ska vara användarens uid och inte mitt egna.
            let myRef = Database.database().reference().child("Users").child(uid).child("Posts").child(seguePostID)
            myRef.removeValue { (error, ref) in
                if error != nil {
                    print("DIDN'T GO THROUGH")
                    return
                }
                print("POST DELETED")
            }
        }
    }
}
