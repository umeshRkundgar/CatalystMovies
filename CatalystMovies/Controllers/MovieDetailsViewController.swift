//
//  MovieDetailsViewController.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    @IBOutlet var posterImage: UIImageView!
    @IBOutlet var backdropImage: UIImageView!
    
    @IBOutlet var movieTitleLabel: UILabel!
    
    @IBOutlet var dgdLabel: UILabel!
    
    @IBOutlet var detailsCollectionView: UICollectionView!
    
    @IBOutlet var aboutDetailsLabel: UILabel!
    
    @IBOutlet var castCollectionView: UICollectionView!
    var releasedate:String?
    var image:UIImage?
    var backdImage:UIImage?
    var movieTitle:String?
    var details = ["About Movie","Cast"]
    var selectedIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Details"
        // print("Data: \(String(describing: releasedate))")
        print("Image is nil?: \(image == nil)")
        posterImage.image = image
        backdropImage.image = backdImage
        movieTitleLabel.text = movieTitle
        dgdLabel.text = releasedate
        posterImage.layer.cornerRadius = 10
        backdropImage.layer.cornerRadius = 5
        detailsCollectionView.delegate = self
        detailsCollectionView.dataSource = self
        castCollectionView.delegate = self
        castCollectionView.dataSource = self
        
        //aboutDetailsLabel.isHidden = true
        castCollectionView.isHidden = true
    }
    
    
}
extension MovieDetailsViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == detailsCollectionView{
            return details.count
        }else{
            return 6
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == detailsCollectionView{
            
            let detailsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieDetails", for: indexPath) as! DetailsCollectionViewCell
            detailsCell.detailsTitle.text = details[indexPath.row]
            detailsCell.configure(with: details[indexPath.row], isSelected: indexPath.row == selectedIndex)
            return detailsCell
        }else{
            let castCell = collectionView.dequeueReusableCell(withReuseIdentifier: "castCell", for: indexPath) as! CastCollectionViewCell
            
            return castCell
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == detailsCollectionView {
            selectedIndex = indexPath.row
            detailsCollectionView.reloadData()
            switch selectedIndex{
            case 0:
                print("0")
                aboutDetailsLabel.isHidden = false
                castCollectionView.isHidden = true
            case 1:
                print("1")
                aboutDetailsLabel.isHidden = true
                castCollectionView.isHidden = false
            default:
                print("Unkonw")
            }
        }
    }
    
}
