//
//  MovieDetailsViewController.swift
//  CatalystMovies
//
//  Created by Mac on 26/02/25.
//

import UIKit
import AVKit
class MovieDetailsViewController: UIViewController {
    //MARK: - OutLets
    @IBOutlet var posterImage: UIImageView!
    @IBOutlet var backdropImage: UIImageView!
    @IBOutlet var movieTitleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var trailerButton: UIButton!
    @IBOutlet var detailsCollectionView: UICollectionView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var castCollectionView: UICollectionView!
    
    //MARK: - Properties
    var movieID: Int?
    var movieTitle:String?
    var image:UIImage?
    var backdImage:UIImage?
    var releasedate:String?
    var descriptionMovie:String?
    var castMember: [Cast] = []
    var duration: Int?
    var genres: [String] = []
    var trailerURL: String?
    
    var details = ["About Movie","Cast"]
    var selectedIndex = 0
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        setupCollectionViews()
        getMovieData()
        
        
        if let movieID = movieID{
            fetchMovieDetails(movieID: movieID)
            fetchCastDetails(movieID: movieID)
            fetchMovieTrailer(movieID: movieID)
        }
    }
    
    //MARK: - initial setup
    private func  initialSetup(){
        self.title = "Details"
        posterImage.layer.cornerRadius = 10
        backdropImage.layer.cornerRadius = 5
        trailerButton.isHidden = true
    }
    
    //MARK: - setup Collection Views
    private func setupCollectionViews(){
        detailsCollectionView.delegate = self
        detailsCollectionView.dataSource = self
        castCollectionView.delegate = self
        castCollectionView.dataSource = self
        castCollectionView.isHidden = true
    }
    
    //MARK: get Data
    private func getMovieData(){
        movieTitleLabel.text = movieTitle
        posterImage.image = image
        backdropImage.image = backdImage
        dateLabel.text = releasedate
        descriptionLabel.text = descriptionMovie
    }
    //MARK: - fetch Cast Details
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
    //MARK: - fetch Movie Details
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
                }
            case .failure(let error):
                print("Error fetching movie details: \(error.localizedDescription)")
            }
        }
    }
    //MARK: - fetch Movie Trailer
    private func fetchMovieTrailer(movieID: Int) {
        APIService.shared.fetchTrailer(movieID: movieID) { [weak self] result in
            switch result {
            case .success(let trailerURL):
                DispatchQueue.main.async {
                    self?.trailerURL = trailerURL
                    self?.trailerButton.isHidden = false
                }
            case .failure(let error):
                print("Error fetching trailer: \(error.localizedDescription)")
            }
        }
    }
    //MARK: - Trailer Action
    @IBAction func watchTrailerTapped(_ sender: UIButton) {
        guard let trailerURL = trailerURL else { return }
        
        let trailerVC = TrailerViewController()
        trailerVC.trailerURL = trailerURL
        present(trailerVC, animated: true)
    }
    
}
//MARK: - UICollectionViewDelegate & UICollectionViewDataSource
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
                descriptionLabel.isHidden = false
                castCollectionView.isHidden = true
            case 1:
                print("1")
                descriptionLabel.isHidden = true
                castCollectionView.isHidden = false
            default:
                print("Unkonw")
            }
        }
    }
    
}
