//
//  CastCollectionViewCell.swift
//  CatalystMovies
//
//  Created by Mac on 27/02/25.
//

import UIKit

class CastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        image.layer.cornerRadius = 100/2
        
    }
}
