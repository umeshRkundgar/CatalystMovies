//
//  MovieCollectionViewCell.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet var posterImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        posterImageView.layer.cornerRadius = 5
    }

}
