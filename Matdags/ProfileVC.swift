//  ProfileVC.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-10-05.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var profileWrapperViewOutlet: UIView!
    @IBOutlet weak var profileInfoViewOutlet: UIView!
    @IBOutlet weak var profilePhotoOutlet: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePhotoOutlet.layer.cornerRadius = profilePhotoOutlet.frame.size.height / 2
//        profilePhotoOutlet.layer.borderWidth = 5.0
        profilePhotoOutlet.layer.borderColor = UIColor.white.cgColor
        profilePhotoOutlet.clipsToBounds = true
        profilePhotoOutlet.layoutIfNeeded()
        
    }
    
    
}

//extension UIView {
//
//    @IBInspectable var cornerRadius: CGFloat {
//
//        get{
//            return layer.cornerRadius
//        }
//        set {
//            layer.cornerRadius = newValue
//            layer.masksToBounds = newValue > 0
//        }
//    }
//
//    @IBInspectable var borderWidth: CGFloat {
//        get {
//            return layer.borderWidth
//        }
//        set {
//            layer.borderWidth = newValue
//        }
//    }
//
//    @IBInspectable var borderColor: UIColor? {
//        get {
//            return UIColor(cgColor: layer.borderColor!)
//        }
//        set {
//            layer.borderColor = borderColor?.cgColor
//        }
//    }
//}

