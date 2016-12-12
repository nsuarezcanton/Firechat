//
//  Extensions.swift
//  Firechat
//
//  Created by Nicolas Suarez-Canton Trueba on 12/12/16.
//  Copyright © 2016 Nicolas Suarez-Canton Trueba. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        
        // otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print("Error fetching image from Firebase.")
                return
            }

            DispatchQueue.main.async(execute: {
                if let dowloadedImage = UIImage(data: data!){
                    imageCache.setObject(dowloadedImage, forKey: urlString as String as AnyObject)
                    self.image = dowloadedImage
                }
            })
            
        }).resume()
    }
}
