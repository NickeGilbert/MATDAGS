//
//  bildflodeViewController.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2017-09-15.
//  Copyright © 2017 Nicklas Gilbertson. All rights reserved.
//

import UIKit

class ImageFeedVC: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navTitle: UINavigationItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navTitle.title = "Matdags"
        
        self.navBar.setBackgroundImage(UIImage(), for: .default)
        //self.navBar.shadowImage = UIImage()
        self.navBar.isTranslucent = true
    }
}
