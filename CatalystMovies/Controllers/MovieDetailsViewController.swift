//
//  MovieDetailsViewController.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import UIKit
import WebKit
class MovieDetailsViewController: UIViewController {
    @IBOutlet var posterImage: UIImageView!
    @IBOutlet var backdropImage: UIImageView!
    @IBOutlet var movieTitleLabel: UILabel!
    @IBOutlet var dgdLabel: UILabel!
    
    @IBOutlet var durationLabel: UILabel!
    
    @IBOutlet var genreLabel: UILabel!
    
    @IBOutlet var trailerButton: UIButton!
    
    @IBOutlet var detailsCollectionView: UICollectionView!
    @IBOutlet var aboutDetailsLabel: UILabel!
    @IBOutlet var castCollectionView: UICollectionView!
    
    var movieID: Int?
    var movieTitle:String?
    var image:UIImage?
    var backdImage:UIImage?
    var releasedate:String?
    var descriptionMovie:String?
    var castMember: [Cast] = [] //List of cast members
    var duration: Int?
    var genres: [String] = []
    var trailerURL: String?
    
    var details = ["About Movie","Cast"]
    var selectedIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Details"
        // print("Data: \(String(describing: releasedate))")
        print("Image is nil?: \(image == nil)")
        movieTitleLabel.text = movieTitle
        posterImage.image = image
        backdropImage.image = backdImage
        dgdLabel.text = releasedate
        aboutDetailsLabel.text = descriptionMovie
        posterImage.layer.cornerRadius = 10
        backdropImage.layer.cornerRadius = 5
        detailsCollectionView.delegate = self
        detailsCollectionView.dataSource = self
        castCollectionView.delegate = self
        castCollectionView.dataSource = self
        
        //aboutDetailsLabel.isHidden = true
        castCollectionView.isHidden = true
        trailerButton.isHidden = true
        if let movieID = movieID{
            fetchMovieDetails(movieID: movieID)
            fetchCastDetails(movieID: movieID)
            fetchMovieTrailer(movieID: movieID)
        }
        
    }
    private func fetchCastDetails(movieID: Int) {
            APIService.shared.fetchCast(movieID: movieID) { [weak self] result in
                switch result {
                case .success(let cast):
                    self?.castMember = cast
                    DispatchQueue.main.async {
                        self?.castCollectionView.reloadData()
                    }
                case .failure(let error):
                    print("Error fetching cast: \(error.localizedDescription)")
                }
            }
        }
    private func fetchMovieDetails(movieID: Int) {
        APIService.shared.fetchMovieDetails(movieID: movieID) { [weak self] result in
            switch result {
            case .success(let movieDetails):
                self?.duration = movieDetails.runtime
                self?.genres = movieDetails.genres.map { $0.name }

                DispatchQueue.main.async {
                    self?.durationLabel.text = " - \(self?.duration ?? 0) min"
                    if let firstGenre = self?.genres.first {
                                        self?.genreLabel.text = " - \(firstGenre)"
                                    } else {
                                        self?.genreLabel.text = "Genre: N/A"
                                    }
//                    self?.genreLabel.text = "Genres: \(self?.genres.joined(separator: ", ") ?? "N/A")"
                }
            case .failure(let error):
                print("Error fetching movie details: \(error.localizedDescription)")
            }
        }
    }
    private func fetchMovieTrailer(movieID: Int) {
            APIService.shared.fetchTrailer(movieID: movieID) { [weak self] result in
                switch result {
                case .success(let trailerURL):
                    DispatchQueue.main.async {
                        self?.trailerURL = trailerURL
                        self?.trailerButton.isHidden = false // Show button when trailer is available
                    }
                case .failure(let error):
                    print("Error fetching trailer: \(error.localizedDescription)")
                }
            }
        }
    @IBAction func watchTrailerTapped(_ sender: UIButton) {
        if let url = trailerURL, let trailerURL = URL(string: url) {
                    UIApplication.shared.open(trailerURL)
                }
    }
}
extension MovieDetailsViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == detailsCollectionView{
            return details.count
        }else{
            return castMember.count
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
            let castMembers = castMember[indexPath.row]
                        castCell.nameLabel.text = castMembers.name
                        castCell.image.loadImage(from: castMembers.profileURL)
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
