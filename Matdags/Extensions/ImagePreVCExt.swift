//
//  ImagePreVCExt.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-01-25.
//  Copyright © 2018 Matdags. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Firebase

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
