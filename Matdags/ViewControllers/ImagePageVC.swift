//
//  ImagePageVC.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2017-11-05.
//  Copyright © 2017 Matdags. All rights reserved.
//

import UIKit
import Firebase

class ImagePageVC: UIViewController {

    @IBOutlet var myImageView: UIImageView!
    var posts = [Post]()
    
    @IBOutlet var collectionFeed: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadImages()
        // Do any additional setup after loading the view.
    }
    
    func downloadImages() {
        let dbref = Database.database().reference()
        
        dbref.child("Posts").queryOrdered(byChild: "likes").queryLimited(toLast: 10).observeSingleEvent(of: .value) { (snapshot) in
            let postsSnaps = snapshot.value as! [String : AnyObject]
            for (_,post) in postsSnaps {
                let appendPost = Post()
                if let pathToImage = post["pathToImage"] as? String {
                    
                    appendPost.pathToImage = pathToImage
                    print(appendPost)
                    self.posts.append(appendPost)
                }
            }
            self.collectionFeed.reloadData()
        }
        dbref.removeAllObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
