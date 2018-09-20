//
//    CachedImageView.swift
//
//    Copyright (c) 2018 avitron01
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//

import UIKit

class CachedImageView: UIImageView {
    static let imageCache = NSCache<NSString, DiscardableImage>()
    
    func loadImage(for url: URL, completion: (() -> ())? = nil) {
        image = nil
        
        let urlString = url.absoluteString as NSString
        
        if let cachedItem = CachedImageView.imageCache.object(forKey: urlString) {
            image = cachedItem.image
            completion?()
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion?()
                return
            }
            
            guard let imageData = data, let image = UIImage(data: imageData) else {
                completion?()
                return
            }
            
            let cacheItem = DiscardableImage(image)
            CachedImageView.imageCache.setObject(cacheItem, forKey: urlString)
            
            DispatchQueue.main.async {
                self.alpha = 0.0
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
                    self.image = image
                    self.alpha = 1.0
                }, completion: nil)
                completion?()
            }
            }.resume()
    }
}
