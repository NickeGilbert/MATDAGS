//  ImageFeedVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-09-15.
//  Copyright © 2017 Nicklas Gilbertson. All rights reserved.

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit

class ImageFeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate {
   
    @IBOutlet var collectionFeed: UICollectionView!
    
    var s_item : Images? 
    var database: Database!
    var databaseref: DatabaseReference!
    var picArray = [UIImage] ()
    
    var taBortArray:[String] = ["1", "2", "3", "4", "5", "6", "1", "2", "3", "4", "5", "6", "1", "2", "3", "4", "5", "6", "1", "2", "3", "4", "5", "6"] //TEST ARRAY, SKA TAS BORT SEN
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taBortArray.count //Ska vara picArray
    }
    
    //TEST FÖR ATT FÅ UT NÅGOT PÅ SKÄRMEN, KAN TAS BORT SEN
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionWindow", for: indexPath) as! ImageFeedCell
        cell.myImages.image = UIImage(named: taBortArray[indexPath.row] + ".jpg")
        return cell
    }
    
    
    //DENNA ÄR DEN RIKTIGA SOM SKA ANVÄNDAS
   /* func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionWindow", for: indexPath) as! ImageFeedCell
        
        print("Nu sätts bilden i Collection View")
        cell.myImages.image = picArray[indexPath.row] as UIImage
        return cell
    }*/
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let storleken = CGSize(width: self.view.frame.width/3.1, height: self.view.frame.width/3)        
        return storleken
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        downloadImages()
    }
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(Auth.auth().currentUser?.uid == nil) {
            performSegue(withIdentifier: "logout", sender: nil)
        }
        else{
            print("INLOGGED 2 BUDDY")
        }
    }
    
    func downloadImages() { //FUNKTIONEN SOM ANVÄNDS NÄR KAMERAN ÄR KOPPLAD
        
      /*let storageRef = Storage.storage().reference()
      let imagesRef = storageRef.child("images/"+s_item!.¶)
        
        imagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Något fick fel i bildhämtning")
            } else {
                print("Bildhämtningen gick bra!")
                let tempImage = UIImage(data: data!)!
                self.picArray.append(tempImage)
                self.collectionFeed.reloadData()
            }
        }*/
    }

    @IBAction func loggaOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let loginManager = FBSDKLoginManager()
            loginManager.logOut() // this is an instance function
            performSegue(withIdentifier: "logout", sender: nil)
            print("U JUST LOGGED OUT BUDDY :D")
        } catch {
            print("U GOT AN ERROR BUDDY ;)")
        }
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "cameraSeg", sender: nil)
    }
}
