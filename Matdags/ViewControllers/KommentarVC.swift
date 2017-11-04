import UIKit
import Firebase
import FirebaseDatabase

class KommentarVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {
   
    @IBOutlet var bottomScrollView: NSLayoutConstraint!
    @IBOutlet var commentSection: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardHide(notification:)), name: .UIKeyboardWillHide, object: nil)

    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func kommentarBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func keyBoardShow(notification: NSNotification) {
        print("VISA")
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
  
            self.bottomScrollView.constant = endFrame?.size.height ?? 0.0

        }
    }
    
    @objc func keyBoardHide(notification: NSNotification) {
        print("HIDE")
       self.bottomScrollView.constant = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField == commentSection)
            {
                print("SKICKA")
            }
            return true
        }
}
