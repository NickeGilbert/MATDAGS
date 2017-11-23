//  ProfileVC.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-10-05.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

class ProfileVC: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout   {
    
    @IBOutlet var profileCollectionFeed: UICollectionView!
    @IBOutlet var profileImageCell: UICollectionViewCell!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profilePictureOutlet: UIImageView!
    var FBdata : Any?
    
    let TaBortArray:[String] = ["1","2","3","4","5","6","1","2","3","4","5","6","1","2","3","4","5","6"]
    
    override func viewDidLoad() {
        
        resizeImage()
       
        if(FBSDKAccessToken.current() != nil) {
            
            profileNameLabel.text = ""
            if FBSDKAccessToken.current() != nil {
                fetchProfile()
            }
            
            let url = URL(string: "http://graph.facebook.com/"+FBSDKAccessToken.current().userID+"/picture?type=large")
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error ) in
                
                if error != nil {
                    print("ERROR")
                } else {
                    print("Checkpoint 1")
                    var documentsDirectory:String?
                    var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory , .userDomainMask, true)
                    
                    if paths.count > 0 {
                        print("Checkpoint 2")
                        documentsDirectory = paths[0]
                        let savePath = documentsDirectory! + "/.jpg"
                        FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
                        
                        DispatchQueue.main.async {
                            print("Checkpoint 3")
                            print(savePath)
                            self.profilePictureOutlet.image = UIImage(named: savePath)
                        }
                    }
                }
            }
            task.resume()
            resizeImage()
        }else {
            
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func resizeImage(){
        profilePictureOutlet.layer.cornerRadius = profilePictureOutlet.frame.size.height / 2
        profilePictureOutlet.clipsToBounds = true
        self.profilePictureOutlet.layer.borderColor = UIColor.white.cgColor
        self.profilePictureOutlet.layer.borderWidth = 2
    }
    
    func fetchProfile() {
        
//        FBSDKAccessToken.current().userID
        
//        var profile_img_url = "http://graph.facebook.com/"+FBSDKAccessToken.current().userID+"/picture?type=square"
//        print(profile_img_url)

        let parameters = ["fields": "email, name, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) -> Void in
            
            if error != nil {
                print("\n",error!,"\n")
                return
            }
            
            let request = FBSDKGraphRequest(graphPath:"me", parameters:parameters)
            
            // Send request to Facebook
            request!.start {
                (connection, result, error) in
                if error != nil {
                    // Some error checking here
                }
                    
                else {
                    let fbRes = result as! NSDictionary
                    
                    print(fbRes)
                    self.profileNameLabel.text = fbRes.value(forKey: "name") as? String
//                    self.profilePictureOutlet.image = (URL: profile_img_url)
                }
            }
        }
    }
    
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TaBortArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! ProfileCell
        cell.myProfileImageCollection.image = UIImage(named: TaBortArray[indexPath.row] + ".jpg")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width/3.2, height: self.view.frame.width/3.2)
        return size
    }
}
