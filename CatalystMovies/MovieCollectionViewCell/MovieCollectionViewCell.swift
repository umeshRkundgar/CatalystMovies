//
//  MovieCollectionViewCell.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet var posterImageView: UIImageView!
    
    @IBOutlet var indexLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        posterImageView.layer.cornerRadius = 5
        indexLabel.layer.cornerRadius = 50/2
                indexLabel.layer.masksToBounds = true
                indexLabel.backgroundColor = .black.withAlphaComponent(0.5)
                indexLabel.textColor = .white
    }

}
