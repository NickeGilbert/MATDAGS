//  NavC.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-10-07.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit

class NavC : UINavigationController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //NavigationView Stuff
        self.navigationController?.view.backgroundColor = .clear
        
        //NavigationBar Stuff
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.tintColor = .black
        self.navigationBar.backgroundColor = .clear
        self.navigationBar.isTranslucent = true
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.topItem?.title = ""
        
    }
    
}
