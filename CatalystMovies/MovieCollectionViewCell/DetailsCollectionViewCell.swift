//
//  DetailsCollectionViewCell.swift
//  CatalystMovies
//
//  Created by Mac on 27/02/25.
//

import UIKit

class DetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet var detailsTitle: UILabel!
    
    @IBOutlet var underlineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        underlineView.backgroundColor = .clear
    }
    
    func configure(with title: String, isSelected: Bool) {
        detailsTitle.text = title
        underlineView.backgroundColor = isSelected ? .gray : .clear
    }
}
