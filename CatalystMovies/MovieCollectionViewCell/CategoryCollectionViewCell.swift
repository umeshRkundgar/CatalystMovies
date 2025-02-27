//
//  CategoryCollectionViewCell.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var underlineView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        underlineView.backgroundColor = .clear
    }
    
    func configure(with text: String, isSelected: Bool) {
        categoryLabel.text = text
        categoryLabel.textColor = isSelected ? .white : .gray
        underlineView.backgroundColor = isSelected ? .white : .clear
        
    }
    
    
}
