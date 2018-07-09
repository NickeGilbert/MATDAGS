//  CameraImgPreVC.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-10-10.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import AVFoundation
import Firebase
import CoreImage
import Photos

class ImagePreVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIToolbarDelegate {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var vegFood: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var descriptionFieldLines: UITextView!
    @IBOutlet weak var filterScrollView: UIScrollView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var AllowSavePhotoView: UIView!
    @IBOutlet weak var AllowSavePhotoViewTopConstraint: NSLayoutConstraint!
    
    var CIFilterNames = ["CIPhotoEffectChrome",
                         "CIPhotoEffectFade",
                         "CIPhotoEffectInstant",
                         "CIPhotoEffectNoir",
                         "CIPhotoEffectProcess",
                         "CIPhotoEffectTonal",
                         "CIPhotoEffectTransfer"]
    
    var vegFoodBool : Bool = false
    var commentBool : Bool = false
    var hiddenTextfield = true
    
    //CIFilter Stuff
    let context = CIContext()
    
    var image: UIImage!
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photo.image = self.image
        
        filterScrollView.isHidden = true
        
        loadFilters()
        
        descriptionFieldLines.delegate = self
        descriptionFieldLines.isHidden = true
        descriptionFieldLines.contentInset = UIEdgeInsetsMake(40, 5, 5, 5)
        
        menuView.layer.cornerRadius = 10
        menuView.clipsToBounds = true
        AllowSavePhotoViewTopConstraint.constant = view.frame.height
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)

        descriptionFieldLines.isHidden = true
        filterScrollView.isHidden = true
        filterButton.setImage(UIImage(named: "filter"), for: .normal)
        if descriptionFieldLines.text == "" {
            commentBtn.setImage(UIImage(named: "commentUse2Final"), for: .normal)
        } else {
            return
        }
    }
    
    func loadFilters() {
        //ToDo: Användaren ska kunna ta bort filter
        
        //Init Button
        let buttonPadding = CGFloat(10)
        var xPosition = CGFloat(0)
        let buttonWidth = CGFloat(self.view.frame.width / 3)
        let buttonHeight = filterScrollView.frame.height
        
        //Scrollview Stuff
        let resizedImage = AppDelegate.instance().resizeImage(image: photo.image!, targetSize: CGSize.init( width: buttonWidth, height: buttonHeight))
        let contentWidth = (buttonWidth + buttonPadding) * CGFloat(CIFilterNames.count) - buttonPadding
        
        for i in 0..<CIFilterNames.count {
            let coreImage = CIImage(image: resizedImage)
            let previewImageButton = UIButton()
            let filter = CIFilter(name: "\(CIFilterNames[i])")
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter?.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = context.createCGImage(filteredImageData, from: filteredImageData.extent)
            let imageForButton = UIImage(cgImage: filteredImageRef!)
            
            previewImageButton.tag = i
            previewImageButton.addTarget(self, action: #selector(previewImageButtonClicked), for: .touchUpInside)
            previewImageButton.setImage(imageForButton, for: .normal)
            previewImageButton.frame = CGRect(x: xPosition, y: 0, width: buttonWidth, height: buttonHeight)
            
            xPosition += buttonWidth + buttonPadding
            
            filterScrollView.addSubview(previewImageButton)
        }
        
        filterScrollView.contentSize = CGSize(width: contentWidth, height: filterScrollView.frame.height)
    }
    
    @objc func previewImageButtonClicked(sender: UIButton) {
        photo.image = self.image!
        
        let coreImage = CIImage(image: photo.image!)
        let filter = CIFilter(name: "\(CIFilterNames[sender.tag])")
        filter!.setDefaults()
        filter!.setValue(coreImage, forKey: kCIInputImageKey)
        let filteredImageData = filter?.value(forKey: kCIOutputImageKey) as! CIImage
        let filteredImageRef = context.createCGImage(filteredImageData, from: filteredImageData.extent)
        let imageForPhoto = UIImage(cgImage: filteredImageRef!, scale: photo.image!.scale, orientation: photo.image!.imageOrientation)
        
        photo.image = imageForPhoto
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    
        descriptionFieldLines.isHidden = true
        if descriptionFieldLines.text == "" {
            commentBtn.setImage(UIImage(named: "commentButton50"), for: .normal)
        }else{

        }
        return true
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let text = textField.text!
//        let maxLength = text.count + string.count - range.length
//        return maxLength <= 10
//    }
    
    @IBAction func postButton(_ sender: Any) {
        UploadImageToFirebase(in: dispatchGroup)
    }
    
    @IBAction func saveLocalButton(_ sender: Any) {
        
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
              print("already auth")
              UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil)
              
              let alert = UIAlertController(title: "Photo saved", message: "", preferredStyle: UIAlertControllerStyle.alert)
              
              alert.addAction(UIAlertAction(title: "Oh Yeah", style: UIAlertActionStyle.default, handler:{ action in
                alert.dismiss(animated: true, completion: nil)
              }))
              self.present(alert, animated: true, completion: nil)
                
            case .denied:
                print("permission denied")
                
                let alert = UIAlertController(title: "Can't save photo", message: "We dont have the permissions, go to Settings and add the rights for Superfoodie", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Alright", style: UIAlertActionStyle.default, handler:{ action in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
                
            case .notDetermined:
                print("Permission Not Determined")
                
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                    self.AllowSavePhotoViewTopConstraint.constant = 0
                    self.view.layoutIfNeeded()
                })
                
                
            case .restricted:
                print("permission restricted")
                
            default:
                break
            }
        
    }
    
    @IBAction func declineButtonAction(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.AllowSavePhotoViewTopConstraint.constant = self.view.frame.height
            self.view.layoutIfNeeded()
        })
    }
    

    
    @IBAction func ApprovButtonAction(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status == PHAuthorizationStatus.authorized{
                print("access given")
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil)
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                        self.AllowSavePhotoViewTopConstraint.constant = self.view.frame.height
                        self.view.layoutIfNeeded()
                    })
                    let alert = UIAlertController(title: "Photo saved", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Oh Yeah", style: UIAlertActionStyle.default, handler:{ action in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }

            }else{
                print("restriced manually")
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                        self.AllowSavePhotoViewTopConstraint.constant = self.view.frame.height
                        self.view.layoutIfNeeded()
                    })
                }
            }
        })
        
    }
    
    
    
    
    
    
    
    @IBAction func vegFoodAction(_ sender: UIButton) {
        if vegFoodBool  == false {
            vegFood.setImage(UIImage(named: "vegButton100.png"), for: .normal)
            vegFoodBool = true
        }else{
            vegFood.setImage(UIImage(named: "vegButtonUse2Final.png"), for: .normal)
            vegFoodBool = false
        }
    }
    
    func addToolbar() {

        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(self.ImagePreVCClearText)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.ImagePreVCDoneEditing)),]

        numberToolbar.sizeToFit()
        descriptionFieldLines.inputAccessoryView = numberToolbar
    }
    
    @objc func ImagePreVCClearText() {
        descriptionFieldLines.text = ""
        descriptionFieldLines.layoutIfNeeded()
    }
    @objc func ImagePreVCDoneEditing() {
        self.view.endEditing(true)
        
        descriptionFieldLines.isHidden = true
        filterScrollView.isHidden = true
        filterButton.setImage(UIImage(named: "filter"), for: .normal)
        if descriptionFieldLines.text == "" {
            commentBtn.setImage(UIImage(named: "commentUse2Final"), for: .normal)
        } else {
            return
        }
    }
    
    @IBAction func commentClick(_ sender: UIButton) {
        addToolbar()
        commentBtn.setImage(UIImage(named: "commentButton50orange"), for: .normal)
        if descriptionFieldLines.isHidden == true {
            descriptionFieldLines.isHidden = false
            descriptionFieldLines.becomeFirstResponder()
        }else{
            descriptionFieldLines.isHidden = true
        }
    }
    @IBAction func filterButtonClicked(_ sender: Any) {
        print("\nYou clicked the filter button!")
        
        if filterScrollView.isHidden {
            filterScrollView.isHidden = false
            filterButton.setImage(UIImage(named: "filterUse2Final"), for: .normal)
        } else {
            filterScrollView.isHidden = true
            filterButton.setImage(UIImage(named: "filter"), for: .normal)
        }
    }
    
    func UploadImageToFirebase(in dispatchGroup: DispatchGroup) {
        AppDelegate.instance().showActivityIndicator()
        let uid = Auth.auth().currentUser?.uid
        let database = Database.database().reference(withPath: "Posts")
        let usrdatabase = Database.database().reference(withPath: "Users")
        let storage = Storage.storage().reference().child("images").child(uid!)
        let key = database.childByAutoId().key
        let imageRef = storage.child("\(key)")
        let imageRef256 = storage.child("\(key)256")
        let resizedImage = AppDelegate.instance().resizeImage(image: photo.image!, targetSize: CGSize.init(width: 256, height: 256))
        let fullImage = AppDelegate.instance().resizeImage(image: photo.image!, targetSize: CGSize.init(width: 1024, height: 1024))
        
        //Datum
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        let currentDate = formatter.string(from: date)
        
        //Timestamp
        let timestamp = Date().timeIntervalSince1970
        
        let prefs = UserDefaults.standard
        let profileImagePhoto = prefs.string(forKey: "userProfilePhoto")
        
        if profileImagePhoto != nil {
            let postfeed = ["userID" : uid!,
                            "timestamp": String(timestamp),
                            "date": currentDate,
                            "rating" : 0,
                            "alias" : Auth.auth().currentUser!.displayName!,
                            "imgdescription" : self.descriptionFieldLines.text!,
                            "postID" : key,
                            "usersRated" : 0,
                            "profileImageURL" : profileImagePhoto!,
                            "vegetarian" : vegFoodBool] as [String : Any]
            database.child("\(key)").updateChildValues(postfeed)
        }else{
            let postfeed = ["userID" : uid!,
                            "timestamp": String(timestamp),
                            "date": currentDate,
                            "rating" : 0,
                            "alias" : Auth.auth().currentUser!.displayName!,
                            "imgdescription" : self.descriptionFieldLines.text!,
                            "postID" : key,
                            "usersRated" : 0,
                            "vegetarian" : vegFoodBool] as [String : Any]
            database.child("\(key)").updateChildValues(postfeed)
        }
        
        
        let usrPostFeed = ["date" : currentDate,
                           "postID" : key,
                           "vegetarian" : vegFoodBool] as [String : Any]
        
        usrdatabase.child("\(uid!)").child("Posts").child("\(key)").updateChildValues(usrPostFeed)
        
        
        //Bild i full storlek
        if let imageData = UIImageJPEGRepresentation(fullImage, 0.8) {
            dispatchGroup.enter()
            let uploadTask = imageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                    print(error!)
                    return
                }
                let firstURL = metadata?.downloadURL()?.absoluteString
                if firstURL != nil {
                    let postURL = ["pathToImage" : firstURL!]
                    database.child("\(key)").updateChildValues(postURL)
                    usrdatabase.child("\(uid!)").child("Posts").child("\(key)").updateChildValues(postURL)
                    print("\n Image uploaded! \n")
                } else {
                    print("\n Could not allocate URL for full size image. \n")
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                }
                dispatchGroup.leave()
            })
            uploadTask.resume()
        }
        
        if let imageData256 = UIImageJPEGRepresentation(resizedImage, 0.8) {
            dispatchGroup.enter()
            let uploadTask256 = imageRef256.putData(imageData256, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                    print(error!)
                    return
                }
                let secondURL = metadata?.downloadURL()?.absoluteString
                if secondURL != nil {
                    let postURL = ["pathToImage256" : secondURL!] as [String : Any]
                    database.child("\(key)").updateChildValues(postURL)
                    usrdatabase.child("\(uid!)").child("Posts").child("\(key)").updateChildValues(postURL)
                    print("\n Thumbnail uploaded! \n")
                } else {
                    print("\n Could not allocate URL for resized image. \n")
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                }
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main, execute: {
                    print("\n Async completed \n")
                    AppDelegate.instance().dismissActivityIndicator()
                    self.dismiss(animated: false, completion: nil)
                })
            })
            uploadTask256.resume()
        }
    }
}
