//
//  ViewControllerVCExt.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-01-20.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit
import Firebase

extension UIViewController {
   
    func checkFirebaseInfo(arg: Bool, completion: @escaping (Bool) -> ()) {
        let uid = Auth.auth().currentUser!.uid
        let db = Database.database().reference(withPath: "Users/\(uid)")
        db.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                completion(false)
            } else {
                completion(true)
            }
        })
    }
}
