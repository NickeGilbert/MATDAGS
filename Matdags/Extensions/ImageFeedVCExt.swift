//
//  ImageFeedVCExt.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-01-18.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloadImage(from imgURL: String) {
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, responds, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}
