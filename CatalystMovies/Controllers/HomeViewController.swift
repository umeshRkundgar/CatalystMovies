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
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    let categories = ["Now Playing", "Popular", "Top Rated", "Upcoming"]
    var selectedCategoryIndex = 0
    let viewModel = HomeViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        setupCollectionView(reloadCollectionVIew, scrollDirection: .vertical)
        setupCollectionView(trendingCollectionView, scrollDirection: .horizontal)
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
        trendingCollectionView.reloadData()
    }
    private func setupCollectionView(_ collectionView: UICollectionView, scrollDirection: UICollectionView.ScrollDirection) {
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = scrollDirection
                layout.minimumInteritemSpacing = 5
                layout.minimumLineSpacing = 5
            }
        }
    private func setupBindings() {
        viewModel.onTrendingUpdated = { [weak self] in
            self?.trendingCollectionView.reloadData()
            
        }
        viewModel.onDataUpdated = { [weak self] in
        
            self?.reloadCollectionVIew.reloadData()
        }
        viewModel.onError = { errorMessage in
            print("Error fetching movies: \(errorMessage)")
        }
    }
    
    private func fetchMovies(for category: MovieCategory) {
        activityIndicator.startAnimating()
        viewModel.fetchMovies(for: category)
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        
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
        if collectionView == trendingCollectionView {
                    return viewModel.trendingMovies.count  // ✅ Only trending movies
                } else if collectionView == reloadCollectionVIew {
                    return getMoviesForSelectedCategory().count  // ✅ Category-based movies
                } else {
                    return categories.count  // ✅ Categories
                }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == trendingCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
            let movie = viewModel.trendingMovies[indexPath.row]
                cell.posterImageView.loadImage(from: movie.posterURL)
            cell.indexLabel.text = "\(indexPath.row + 1)"
            return cell
        }else if collectionView == reloadCollectionVIew{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
            cell.indexLabel.isHidden = true
                        let movie = getMoviesForSelectedCategory()[indexPath.row]
                        cell.posterImageView.loadImage(from: movie.posterURL)
            
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
            secondVC.movieID = movie.id  // 🔹 Pass Movie ID for Cast Fetching
                    secondVC.movieTitle = movie.title
                   
            secondVC.descriptionMovie = movie.overview
            secondVC.releasedate = movie.releaseDate//String(movie.releaseDate?.prefix(4) ?? "")
                    let dispatchGroup = DispatchGroup()

                    if let posterURL = movie.posterURL {
                        dispatchGroup.enter()
                        URLSession.shared.dataTask(with: posterURL) { data, _, _ in
                            if let data = data, let image = UIImage(data: data) {
                                secondVC.image = image
                            }
                            dispatchGroup.leave()
                        }.resume()
                    }

                    if let backdropURL = movie.backdropURL {
                        dispatchGroup.enter()
                        URLSession.shared.dataTask(with: backdropURL) { data, _, _ in
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
        }else if collectionView == trendingCollectionView{
            return 10
        }
        return 25
    }
    
    func loadImage(from path: String?, completion: @escaping (UIImage?) -> Void) {
        guard let path = path, let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)") else {
            completion(nil) // If URL is invalid, return nil
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)  // If image fails to load, return nil
                }
            }
        }.resume()
    }
    func showErrorAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
}
