//
//  ViewController.swift
//  CatalystMovies
//
//  Created by Mac on 25/02/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet var trendingCollectionView: UICollectionView!
    
    @IBOutlet var categoryCollectionView: UICollectionView!
    
    @IBOutlet var reloadCollectionVIew: UICollectionView!
    let categories = ["Now Playing", "Popular", "Top Rated", "Upcoming"]
    var selectedCategoryIndex = 0
    let viewModel = HomeViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = reloadCollectionVIew.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 5
        }
        // Register XIB for both collections
        let nib = UINib(nibName: "MovieCollectionViewCell", bundle: nil)
        trendingCollectionView.register(nib, forCellWithReuseIdentifier: "MovieCollectionViewCell")
        trendingCollectionView.dataSource = self
        trendingCollectionView.delegate = self
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        
        let reloadNib = UINib(nibName: "MovieCollectionViewCell", bundle: nil)
        reloadCollectionVIew.register(reloadNib, forCellWithReuseIdentifier: "MovieCollectionViewCell")
        reloadCollectionVIew.dataSource = self
        reloadCollectionVIew.delegate = self
        setupBindings()
        fetchMovies(for: .trending)
        fetchMovies(for: .nowPlaying)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadCollectionVIew.collectionViewLayout.invalidateLayout()
        //reloadCollectionVIew.reloadData()
    }
    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            self?.trendingCollectionView.reloadData()
            self?.reloadCollectionVIew.reloadData()
        }
        viewModel.onError = { errorMessage in
            print("Error fetching movies: \(errorMessage)")
        }
    }
    
    private func fetchMovies(for category: MovieCategory) {
        viewModel.fetchMovies(for: category)
    }
    func getMoviesForSelectedCategory() -> [Movie] {
        switch selectedCategoryIndex {
        case 0: return viewModel.nowPlayingMovies
        case 1: return viewModel.popularMovies
        case 2: return viewModel.topRatedMovies
        case 3: return viewModel.upcomingMovies
        default: return []
        }
    }
}

extension HomeViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == trendingCollectionView || collectionView == reloadCollectionVIew {
            return getMoviesForSelectedCategory().count
        } else {
            return categories.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == trendingCollectionView || collectionView == reloadCollectionVIew{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
            let movies = getMoviesForSelectedCategory()
            if indexPath.row < movies.count{
                let movie = movies[indexPath.row]
                cell.posterImageView.loadImage(from: movie.posterURL)
            }
            return cell
        }else{
            let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            categoryCell.categoryLabel.text = categories[indexPath.row]
            categoryCell.configure(with: categories[indexPath.row], isSelected: indexPath.row == selectedCategoryIndex)
            return categoryCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            selectedCategoryIndex = indexPath.row
            categoryCollectionView.reloadData()
            switch selectedCategoryIndex {
            case 0:
                fetchMovies(for: .nowPlaying)
            case 1:
                fetchMovies(for: .popular)
            case 2:
                fetchMovies(for: .topRated)
            case 3:
                fetchMovies(for: .upcoming)
            default:
                break
            }
        }else if collectionView == reloadCollectionVIew{
            let movie = getMoviesForSelectedCategory()[indexPath.row]
            
            let secondVC = storyboard?.instantiateViewController(withIdentifier: "MovieDetailsViewController") as! MovieDetailsViewController
            secondVC.movieTitle = movie.title
            let date = String(movie.releaseDate.prefix(4))
            secondVC.releasedate = date
            let dispatchGroup = DispatchGroup()
            
            
            if let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath ?? "")") {
                dispatchGroup.enter()
                URLSession.shared.dataTask(with: posterURL) { data, _, error in
                    if let data = data, let image = UIImage(data: data) {
                        secondVC.image = image
                    }
                    dispatchGroup.leave()
                }.resume()
            }
            
            
            if let backdropURL = URL(string: "https://image.tmdb.org/t/p/w500\(movie.backdropPath ?? "")") {
                dispatchGroup.enter()
                URLSession.shared.dataTask(with: backdropURL) { data, _, error in
                    if let data = data, let image = UIImage(data: data) {
                        secondVC.backdImage = image
                    }
                    dispatchGroup.leave()
                }.resume()
            }
            
            
            dispatchGroup.notify(queue: .main) {
                self.navigationController?.pushViewController(secondVC, animated: true)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard collectionView == reloadCollectionVIew else {
            return CGSize(width: 180, height: 250)
        }
        
        let numberOfCellsPerRow: CGFloat = 3
        let totalSpacing: CGFloat = 40
        let interItemSpacing: CGFloat = 5
        
        let availableWidth = collectionView.frame.width - totalSpacing - (interItemSpacing * (numberOfCellsPerRow - 1))
        let cellWidth = availableWidth / numberOfCellsPerRow
        let cellHeight: CGFloat = 180
        
        return CGSize(width: cellWidth, height: cellHeight)
        
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == reloadCollectionVIew {
            return 10
        }
        return 10 
    }
    
    
}
