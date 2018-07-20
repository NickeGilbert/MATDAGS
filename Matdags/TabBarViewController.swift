//
//  TabBarViewController.swift
//  Matdags
//
//  Created by Nicklas Gilbertsson on 2018-07-20.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.items![0].title = NSLocalizedString("home", comment: "")
        tabBar.items![1].title = NSLocalizedString("favorite", comment: "")
        tabBar.items![2].title = NSLocalizedString("profile", comment: "")
        tabBar.items![3].title = NSLocalizedString("search", comment: "")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
