//  ImagePageVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-11-05.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase

class ImagePageSubviewVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    //Main view outlets
    @IBOutlet weak var vegiIcon: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet weak var myImageViewBack: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var starButtons: [UIButton]!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var followerButton: UIButton!
    @IBOutlet weak var unfollowingButton: UIButton!
    @IBOutlet weak var toSubViewButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var settingsOverlayView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableViewConstraintH: NSLayoutConstraint!
    @IBOutlet weak var transperantCloseButton: UIButton!
    
    //Old settings view outlets - cleanup later
    @IBOutlet weak var imagePageSettingsView: UIView!
    @IBOutlet weak var imagePageSettingsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var blockUser: UIButton!
    @IBOutlet weak var reportImage: UIButton!
    @IBOutlet weak var deleteImage: UIButton!
    
    //Comments view outlets
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var zeroCommentsLabel: UILabel!
    
    @IBOutlet weak var topSubView: UIView!
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var subviewUsername: UILabel!
    @IBOutlet weak var subviewProfileImage: UIImageView!
    @IBOutlet weak var subviewCollectionFeed: UICollectionView!
    @IBOutlet weak var subviewFollowButton: UIButton!
    @IBOutlet weak var subviewUnfollowButton: UIButton!
    @IBOutlet weak var topSubviewTopConstraint: NSLayoutConstraint!
    
    //Settings view outlets
    @IBOutlet weak var deleteThisImageButton: UIButton!
    @IBOutlet weak var reportThisImageButton: UIButton!
    @IBOutlet weak var blockThisUserButton: UIButton!
    @IBOutlet weak var settingsViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsViewInner: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var settingsLabel: UILabel!
    
    
    //Fix views in diffrent views outlets
    @IBOutlet weak var bendView: UIView!
    @IBOutlet weak var bendView2: UIView!
    @IBOutlet weak var bendViewInnerTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var ScrollViewHorizSubView: UIScrollView!
    @IBOutlet weak var descriptionLabelSubView: UILabel!
    @IBOutlet weak var noDiscriptionTextImageView: UIImageView!
    @IBOutlet weak var settingsViewCloseButton: UIButton!
    
    
    
    let dispatchGroup = DispatchGroup()
    let uid = Auth.auth().currentUser!.uid
    let db = Database.database()
    let alias = Auth.auth().currentUser!.displayName
    
    var seguePostID : String!
    var users = [User]()
    var peoplelIFollowCount : Int = 0
    var countPeopleThatFollowMe : Int = 0
    var reports : Int = 0
    var reportsOnUsers : Int = 0
    var posts = [Post]()
    var subviews = [Subview]()
    var userFollowing = [String]()
    var commentsRef = Database.database().reference()
    var comments: Array<DataSnapshot> = []
    var starsHighlighted = 0
    var fetchedStars = 0
    var usersRated = 0
    var postRating = 0
    var commentConter: Int = 0
    var commentsCell = [CommentsCell]()
    var arrayOfUsersThatHaveReportedAnImage = [String]()
    var checkBlockedUsers = [String]()
    var myBlockedUsers = [String]()
    
    public var minimumVelocityToHide = 1500 as CGFloat
    public var minimumScreenRatioToHide = 0.5 as CGFloat
    public var animationDuration = 0.2 as TimeInterval
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let clickUITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onSelect(_:)))
        clickUITapGestureRecognizer.delegate = self
        settingsOverlayView?.addGestureRecognizer(clickUITapGestureRecognizer)
        
        zeroCommentsLabel.text = NSLocalizedString("zeroCommentsLabel", comment: "")
        settingsLabel.text = NSLocalizedString("settingsLabel", comment: "")
        blockThisUserButton.setTitle(NSLocalizedString("blockUser", comment: ""), for: .normal)
        reportThisImageButton.setTitle(NSLocalizedString("reportImage", comment: ""), for: .normal)
        deleteThisImageButton.setTitle(NSLocalizedString("eraseImage", comment: ""), for: .normal)
        
        commentsTextView.contentInset = UIEdgeInsetsMake(40, 5, 5, 5)
        bendView.layer.cornerRadius = 10
        bendView.clipsToBounds = true
        bendView2.layer.cornerRadius = 10
        bendView2.clipsToBounds = true
        settingsViewTopConstraint.constant = view.bounds.size.height
        settingsViewInner.layer.cornerRadius = 10
        settingsViewInner.clipsToBounds = true
        myImageView.isUserInteractionEnabled = false
        
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        self.view.addGestureRecognizer(panGesture)
        closeButton.layer.zPosition = 1
        vegiIcon.layer.zPosition = 1
        scrollView.layer.zPosition = 2
        topSubView.layer.zPosition = 3
        commentsView.layer.zPosition = 3
        settingsView.layer.zPosition = 3
        
        ScrollViewHorizSubView.delegate = self
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == ScrollViewHorizSubView {
            let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
            pageControl.currentPage = Int(pageIndex)
        }
    }
    
    // new test swipe down daniel
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen;
        self.modalTransitionStyle = .coverVertical;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .overFullScreen;
        self.modalTransitionStyle = .coverVertical;
    }
    
    // --------------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Clear and start observing comments.
        comments.removeAll()
        commentsRef = commentsRef.child("Posts/\(seguePostID!)/comments")
        observeComments()
        //        print("my image view back hight: ", myImageViewBack.frame.height)
        //
        //        bendViewInnerTopConstraint.constant = myImageViewBack.frame.height - 70
        
        //Sort UI before fetching data.
        sortBeforeFetch()
        
        downloadInfo(in: dispatchGroup, completionHandler: { (true) in
            //self.sortFirebaseInfo()
            self.getStars()
            self.checkUserYouAreFollowing()
            self.getUserThatFollowMeCounter()
            self.checkHowManyReportsUserpostHave()
            self.checkIfUserAlreadyHaveReportedThisImage()
            self.getUserThatIFollowCounter()
            
            //Sort UI after fetching data.
            self.sortAfterFetch()
            
        })
        
    }
    
    
    @IBAction func openSettingsAction(_ sender: Any) {
        
        let animations = {
            self.settingsViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        let completion = { (finished: Bool) in
            self.settingsViewCloseButton.backgroundColor = UIColor.black
            self.settingsViewCloseButton.alpha = 0.1
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.2,
                       animations: animations,
                       completion: completion)
    }
    
    func closeSubView() {
        self.transperantCloseButton.alpha = 0
        let animations = {
            self.topSubviewTopConstraint.constant = self.view.frame.height
            self.view.layoutIfNeeded()
        }
        let completion = { (finished: Bool) in
            self.topSubView.isHidden = true
            
        }
        UIView.animate(withDuration: 0.25,
                       animations: animations,
                       completion: completion)
    }
    
    @IBAction func transperantCloseSubviewAction(_ sender: Any) {
        closeSubView()
    }
    
    @IBAction func closeSettingsAction(_ sender: Any) {
        self.settingsViewCloseButton.backgroundColor = UIColor.clear
        self.settingsViewCloseButton.alpha = 0
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
            self.settingsViewTopConstraint.constant = self.view.bounds.size.height
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func reportImageAction(_ sender: Any) {
        reportThisImage()
    }
    
    @IBAction func blockUserAction(_ sender: Any) {
        reportThisUser()
    }
    
    @IBAction func eraseImageAction(_ sender: Any) {
        deleteThisImage()
    }
    
    func reportThisImage() {
        let alert = UIAlertController(title: NSLocalizedString("reportImageTitle", comment: ""),
                                      message: NSLocalizedString("reportImageMessage", comment: ""),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("reportTitle", comment: ""),
                                      style: .destructive,
                                      handler: { action in
                                        
                                        let alert2 = UIAlertController(title: NSLocalizedString("reportSent", comment: ""),
                                                                       message: NSLocalizedString("reportSentMessage", comment: ""),
                                                                       preferredStyle: .alert)
                                        
                                        self.checkForUIDInReportedImage()
                                        
                                        alert2.addAction(UIAlertAction(title: NSLocalizedString("closeReport", comment: ""),
                                                                       style: .cancel,
                                                                       handler: nil))
                                        
                                        self.present(alert2, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("closeReport", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func reportThisUser() {
        let alert = UIAlertController(title: NSLocalizedString("blockUserTitle", comment: ""),
                                      message: NSLocalizedString("", comment: ""),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("blockUser", comment: ""),
                                      style: .destructive,
                                      handler: { action in
                                        
                                        let alert2 = UIAlertController(title: NSLocalizedString("userIsBlockedTitle", comment: ""),
                                                                       message: NSLocalizedString("userIsBlockedMessage", comment: ""),
                                                                       preferredStyle: .alert)
                                        self.reportUsers()
                                        
                                        alert2.addAction(UIAlertAction(title: NSLocalizedString("userClose", comment: ""),
                                                                       style: .cancel, handler: nil))
                                        self.present(alert2, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("userClose", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true)
    }
    
    func deleteThisImage(){
        let alert = UIAlertController(title: NSLocalizedString("deleteImageTitle", comment: ""),
                                      message: NSLocalizedString("deleteImageMessage", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: ""),
                                      style: .destructive,
                                      handler: { action in self.deletePosts() }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("closeReport", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true)
    }
    
    func customWillDisappear(in dispatchGroup: DispatchGroup, completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        dispatchGroup.enter()
        getInfoForIncremation { (true) in
            if self.posts[0].usersRated == nil || self.posts[0].usersRated == 0 {
                self.usersRated = 0
            } else {
                self.usersRated = self.posts[0].usersRated
            }
            if self.posts[0].rating == nil || self.posts[0].rating == 0 {
                self.postRating = 0
            } else {
                self.postRating = self.posts[0].rating
            }
            self.postStars { (true) in
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main, execute: {
                    completionHandler(true)
                })
            }
        }
    }
    
    func observeComments() {
        commentsRef.observe(.childAdded, with: { (snapshot) -> Void in
            //            print(snapshot.value!)
            self.comments.append(snapshot)
            self.commentsTableView.insertRows(at: [IndexPath(row: self.comments.count-1, section: 0)], with: .automatic)
            
            let size = self.comments.count
            print("HOW MANY COMMENTS", size)
        })
        commentsRef.observe(.childRemoved, with: { (snapshot) -> Void in
            let index = self.indexOfMessage(snapshot)
            self.comments.remove(at: index)
            self.commentsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        })
    }
    
    func indexOfMessage(_ snapshot: DataSnapshot) -> Int {
        var index = 0
        for  comment in self.comments {
            if snapshot.key == comment.key {
                return index
            }
            index += 1
        }
        return -1
    }
    
    func getInfoForIncremation(completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        let getInfo = Post()
        let dbref = db.reference(withPath: "Posts/\(self.posts[0].postID)")
        dbref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                getInfo.rating = dict["rating"] as? Int ?? 0
                getInfo.usersRated = dict["usersRated"] as? Int ?? 0
            }
            completionHandler(true)
        }
    }
    
    func downloadInfo(in dispatchGroup: DispatchGroup, completionHandler: @escaping ((_ exist : Bool) -> Void)) {
        dispatchGroup.enter()
        db.reference(withPath: "Posts/\(seguePostID!)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let getInfo = Post()
                
                self.profileImage.layer.cornerRadius = self.profileImage.frame.height / 2
                self.profileImage.clipsToBounds = true
                
                self.myImageViewBack.downloadImage(from: dictionary["pathToImage"] as? String ?? "")
                self.toSubViewButton.setTitle(dictionary["alias"] as? String ?? "", for: .normal)
                self.descriptionLabel.text = dictionary["imgdescription"] as? String ?? ""
                self.profileImage.downloadImage(from: dictionary["profileImageURL"] as? String ?? "")
                getInfo.pathToImage = dictionary["pathToImage"] as? String ?? ""
                getInfo.rating = dictionary["rating"] as? Int ?? 0
                getInfo.userID = dictionary["userID"] as? String ?? ""
                getInfo.postID = dictionary["postID"] as? String ?? ""
                getInfo.alias = dictionary["alias"] as? String ?? ""
                getInfo.imgdescription = dictionary["imgdescription"] as? String ?? ""
                getInfo.vegi = dictionary["vegetarian"] as? Bool ?? false
                getInfo.usersRated = dictionary["usersRated"] as? Int ?? 0
                self.posts.append(getInfo)
            } else {
                dispatchGroup.leave()
                completionHandler(false)
            }
            dispatchGroup.leave()
            dispatchGroup.notify(queue: .main, execute: {
                completionHandler(true)
            })
        })
    }
    
    @IBAction func followUser(_ sender: Any) {
        followerButton.isHidden = true
        subviewFollowButton.isHidden = true
        subviewUnfollowButton.isHidden = false
        unfollowingButton.isHidden = false
        getFollower()
        addFollower()
    }
    
    @IBAction func commentButtonClick(_ sender: UIButton) {
        addToolbar()
        settingsOverlayView.isHidden = true
        commentsTextView.text = ""
        commentsView.isHidden = false
        commentsTextView.becomeFirstResponder()
    }
    
    func addToolbar() {
        
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.ImagePageVCClose)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(self.ImagePageVCDoneEditing)),]
        
        numberToolbar.sizeToFit()
        commentsTextView.inputAccessoryView = numberToolbar
    }
    
    @objc func ImagePageVCClose() {
        commentsTextView.text = ""
        self.view.endEditing(true)
        settingsOverlayView.isHidden = true
        commentsView.isHidden = true
    }
    
    @objc func ImagePageVCDoneEditing() {
        if commentsTextView.text != "" {
            let postID = self.posts[0].postID
            let postRef = db.reference(withPath: "Posts/\(postID!)/comments")
            let key = postRef.childByAutoId().key
            let commentSend = commentsTextView.text
            
            postRef.child(key).updateChildValues(["uid" : uid,
                                                  "alias" : alias!,
                                                  "comment" : commentSend!] as [String: Any])
            
            self.commentsTextView.resignFirstResponder()
            self.view.endEditing(true)
            self.commentsView.isHidden = true
            
        } else {
            commentsTextView.resignFirstResponder()
            self.view.endEditing(true)
            commentsView.isHidden = true
        }
    }
    
    func sortFirebaseInfo() {
        myImageViewBack.downloadImage(from: self.posts[0].pathToImage)
        toSubViewButton.setTitle(self.posts[0].alias, for: .normal)
        descriptionLabel.text = self.posts[0].imgdescription
    }
    
    @IBAction func imagePageBack(_ sender: Any) {
        customWillDisappear(in: dispatchGroup, completionHandler: { (true) in
            self.posts.removeAll()
            self.subviews.removeAll()
            self.commentsRef.removeAllObservers()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    @IBAction func clickedOnUsername(_ sender: Any) {
        getUserProfileImage { (true) in
            self.downloadImages(completionHandler: { (true) in
                self.settingsOverlayView.isHidden = true
                self.topSubView.isHidden = false
                self.subviewUsername.text = self.posts[0].alias
                
                let animations = {
                    self.topSubviewTopConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }
                let completion = { (finished: Bool) in
                    self.transperantCloseButton.alpha = 0.2
                    self.view.layoutIfNeeded()
                }
                UIView.animate(withDuration: 0.25,
                               animations: animations,
                               completion: completion)
                
            })
        }
    }
    
    
    
    
    @IBAction func reportImage(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("reportImageTitle", comment: ""),
                                      message: NSLocalizedString("reportImageMessage", comment: ""),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("reportTitle", comment: ""),
                                      style: .destructive,
                                      handler: { action in
                                        
                                        let alert2 = UIAlertController(title: NSLocalizedString("reportSent", comment: ""),
                                                                       message: NSLocalizedString("reportSentMessage", comment: ""),
                                                                       preferredStyle: .alert)
                                        
                                        self.checkForUIDInReportedImage()
                                        
                                        alert2.addAction(UIAlertAction(title: NSLocalizedString("closeReport", comment: ""),
                                                                       style: .cancel,
                                                                       handler: nil))
                                        
                                        self.present(alert2, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("closeReport", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        
        self.present(alert, animated: true)
    }
    
    
    
    @IBAction func deleteImage(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("deleteImageTitle", comment: ""),
                                      message: NSLocalizedString("deleteImageMessage", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: ""),
                                      style: .destructive,
                                      handler: { action in self.deletePosts() }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("closeReport", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func unfollowUserButton(_ sender: Any) {
        self.unfollowingButton.isHidden = true
        self.subviewUnfollowButton.isHidden = true
        self.followerButton.isHidden = false
        self.subviewFollowButton.isHidden = false
        unfollowUser()
    }
    
    func deletePosts() {
        db.reference(withPath: "Users/\(uid)/Posts/\(seguePostID!)").removeValue { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            print("\nSuccessfully removed: \(ref)\n")
        }
        
        db.reference(withPath: "Posts/\(seguePostID!)").removeValue { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            print("\nSuccessfully removed: \(ref)\n")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func checkUserYouAreFollowing() {
        //Used by Subview
        db.reference(withPath: "Users/\(uid)/Following").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                for uid in dict {
                    let appendUser = User()
                    appendUser.uid = uid.value as? String ?? ""
                    self.userFollowing.append(appendUser.uid)
                    self.checkUserUid()
                }
            }
        })
    }
    
    func checkUserUid() {
        let userId = self.posts[0].userID!
        
        if uid == userId {
            self.subviewFollowButton.isHidden = true
            self.subviewUnfollowButton.isHidden = true
        } else {
            for user in userFollowing {
                if userId == user {
                    self.followerButton.isHidden = true
                    self.unfollowingButton.isHidden = false
                    self.subviewFollowButton.isHidden = true
                    self.subviewUnfollowButton.isHidden = false
                    break
                } else {
                    self.followerButton.isHidden = false
                    self.unfollowingButton.isHidden = true
                    self.subviewFollowButton.isHidden = false
                    self.subviewUnfollowButton.isHidden = true
                }
            }
        }
    }
    
    
    
    @IBAction func blockUser(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("blockUserTitle", comment: ""),
                                      message: NSLocalizedString("blockUserMessage", comment: ""),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("blockUser", comment: ""),
                                      style: .destructive,
                                      handler: { action in
                                        
                                        let alert2 = UIAlertController(title: NSLocalizedString("userIsBlockedTitle", comment: ""),
                                                                       message: NSLocalizedString("userIsBlockedMessage", comment: ""),
                                                                       preferredStyle: .alert)
                                        self.reportUsers()
                                        
                                        alert2.addAction(UIAlertAction(title: NSLocalizedString("userClose", comment: ""),
                                                                       style: .cancel, handler: nil))
                                        self.present(alert2, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("userClose", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true)
        
    }
    
    @IBAction func reportUserPost(_ sender: Any) {
        //Do not remove
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.comments.count < 1 {
            commentsTableView.isHidden = true
        }else{
            commentsTableView.isHidden = false
        }
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentsCell
        
        let cellHeight = cell.frame.height
        let tableHeight = tableView.frame.height
        
        self.tableViewConstraintH.constant = tableHeight + cellHeight
        
        if let commentDict = comments[indexPath.row].value as? [String : AnyObject] {
            print("Comment dicionery: ",commentDict)
            cell.commentsTextLabel.isHidden = false
            cell.commentsNameLabel.isHidden = false
            cell.commentsTextLabel.text = commentDict["comment"] as? String
            cell.commentsNameLabel.text  = commentDict["alias"] as? String
        }
        
        
        return cell
    }
    
    //UI
    func sortBeforeFetch() {
        toSubViewButton.setTitle("", for: .normal)
        descriptionLabel.text = ""
        commentsTableView.isScrollEnabled = false
        commentsTableView.separatorStyle = .none
        subview.layer.cornerRadius = 10
        subview.clipsToBounds = true
        followerButton.layer.cornerRadius = 5
        followerButton.clipsToBounds = true
        unfollowingButton.layer.cornerRadius = 5
        unfollowingButton.clipsToBounds = true
        subviewFollowButton.layer.cornerRadius = 5
        subviewFollowButton.clipsToBounds = true
        subviewUnfollowButton.layer.cornerRadius = 5
        subviewUnfollowButton.clipsToBounds = true
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        imagePageSettingsView.layer.cornerRadius = 5
        followerButton.backgroundColor = followUserBtn
        unfollowingButton.backgroundColor = unfollowUserBtn
        subviewFollowButton.backgroundColor = followUserBtn
        subviewUnfollowButton.backgroundColor = unfollowUserBtn
        followerButton.isHidden = true
        unfollowingButton.isHidden = true
        subviewFollowButton.isHidden = true
        subviewUnfollowButton.isHidden = true
        vegiIcon.isHidden = true
        
        topSubviewTopConstraint.constant = view.frame.height
        topSubView.isHidden = true
        subview.isHidden = false
        //        commentsTextView.delegate = self
        settingsOverlayView.isHidden = true
        closeButton.isHidden = true
        
        followerButton.setTitle(NSLocalizedString("followButton", comment: ""), for: .normal)
        unfollowingButton.setTitle(NSLocalizedString("followingButton", comment: ""), for: .normal)
        subviewFollowButton.setTitle(NSLocalizedString("followButton", comment: ""), for: .normal)
        subviewUnfollowButton.setTitle(NSLocalizedString("followingButton", comment: ""), for: .normal)
        
        reportImage.setTitle(NSLocalizedString("reportImage", comment: ""), for: .normal)
        blockUser.setTitle(NSLocalizedString("blockUser", comment: ""), for: .normal)
        deleteImage.setTitle(NSLocalizedString("deleteImage", comment: ""), for: .normal)
    }
    
    func sortAfterFetch() {
        if self.posts[0].vegi == false {
            vegiIcon.isHidden = true
        } else {
            vegiIcon.isHidden = false
        }
        
        self.usersRated = self.posts[0].usersRated
        self.postRating = self.posts[0].rating
        
        if self.posts[0].userID != self.uid {
            self.deleteImage.isHidden = true // SOME DUDE
            self.deleteThisImageButton.isEnabled = false
            self.deleteThisImageButton.alpha = 0.2
            self.followerButton.isHidden = false
            self.subviewFollowButton.isHidden = false
            self.imagePageSettingsViewHeightConstraint.constant = 100
        } else {
            self.deleteImage.isHidden = false // MYSELF
            self.deleteThisImageButton.isEnabled = true
            self.reportImage.isHidden = true
            self.reportThisImageButton.isEnabled = false
            self.reportThisImageButton.alpha = 0.2
            self.blockUser.isHidden = true
            self.blockThisUserButton.isEnabled = false
            self.blockThisUserButton.alpha = 0.2
            self.followerButton.isHidden = true
            self.unfollowingButton.isHidden = true
            self.subviewFollowButton.isHidden = true
            self.imagePageSettingsViewHeightConstraint.constant = 50
        }
        closeButton.isHidden = false
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    @IBAction func onSelect(_ sender: Any) {
        settingsOverlayView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}



