//  ImageFeedVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-09-15.
//  Copyright © 2017 Nicklas Gilbertson. All rights reserved.

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class ImageFeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    @IBOutlet var collectionFeed: UICollectionView!
    
    var s_item : Images? 
    var database: Database!
    var databaseref: DatabaseReference!
    var picArray = [UIImage] ()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionWindow", for: indexPath) as! ImageFeedCell
        
        print("Nu sätts bilden i Collection View")
        cell.myImages.image = picArray[indexPath.row] as UIImage
        cell.backgroundColor = .black
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indezPath: IndexPath) -> CGSize {
        
        let storleken = CGSize(width: self.view.frame.width/3.1, height: self.view.frame.width/3)        
        return storleken
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        downloadImages()
    }
    
    func downloadImages() {
        
        let storageRef = Storage.storage().reference()
        let imagesRef = storageRef.child("images/"+s_item!.fbKey)
        
        imagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Något fick fel i bildhämtning")
            } else {
                print("Bildhämtningen gick bra!")
                let tempImage = UIImage(data: data!)!
                self.picArray.append(tempImage)
                self.collectionFeed.reloadData()
            }
        }
    }

    @IBAction func loggaOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            performSegue(withIdentifier: "logout", sender: nil)
            print("Logged out!")
        } catch {
            print("ERROR2")
        }
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "cameraSeg", sender: nil)
    }
}
