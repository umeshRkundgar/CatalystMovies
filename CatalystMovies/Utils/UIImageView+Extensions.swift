//
//  UIImageView+Extensions.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL?) {
        guard let url = url else {
            self.image = UIImage(named: "userImages")
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self.image = UIImage(named: "userImages")
                }
            }
        }
    }
}

