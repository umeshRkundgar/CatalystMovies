//
//  ViewController.swift
//  CatalystMovies
//
//  Created by Mac on 25/02/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var trendingCollectionView: UICollectionView!
    @IBOutlet var categoryCollectionView: UICollectionView!
    @IBOutlet var reloadCollectionVIew: UICollectionView!
    
    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.4) // Dim background
        view.isHidden = true // Hide by default
        view.tag = 999 // Assign tag to identify it
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Properties
    let categories = ["Now Playing", "Popular", "Top Rated", "Upcoming"]
    var selectedCategoryIndex = 0
    let viewModel = HomeViewModel()
    // private var loadingView: UIView?
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadingView.frame = view.bounds
        
        loadingView.isHidden = false
        activityIndicator.startAnimating()
        setupActivityIndicator()
        setupCollectionViews()
        setupBindings()
        fetchMovies(for: .trending)
        fetchMovies(for: .nowPlaying)
        
    }
    // MARK: - Setup Methods
    
    private func setupActivityIndicator() {
        
        loadingView.frame = view.bounds
        view.addSubview(loadingView)
        
        loadingView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        ])
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .gray
        navigationItem.backBarButtonItem = backItem
    }
    private func setupCollectionViews(){
        trendingCollectionView.dataSource = self
        trendingCollectionView.delegate = self
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        reloadCollectionVIew.dataSource = self
        reloadCollectionVIew.delegate = self
        
        let nib = UINib(nibName: "MovieCollectionViewCell", bundle: nil)
        trendingCollectionView.register(nib, forCellWithReuseIdentifier: "MovieCollectionViewCell")
        reloadCollectionVIew.register(nib, forCellWithReuseIdentifier: "MovieCollectionViewCell")
    }
    //MARK: - setupBindings
    private func setupBindings() {
        viewModel.isLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                print("Loading state changed: \(isLoading)")
                if isLoading {
                    self?.loadingView.isHidden = false
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.loadingView.isHidden = true
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        
        
        viewModel.onTrendingUpdated = { [weak self] in
            DispatchQueue.main.async{
                self?.trendingCollectionView.reloadData()
            }
        }
        
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async{
                self?.reloadCollectionVIew.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: errorMessage)
            }
        }
    }
    //MARK: API Calls
    private func fetchMovies(for category: MovieCategory) {
        viewModel.fetchMovies(for: category)
    }
    
    //MARK: Helper Methods
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

//MARK: - UICollectionViewDelegate and UICollectionViewDataSource and UICollectionViewDelegateFlowLayout
extension HomeViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == trendingCollectionView {
            return viewModel.trendingMovies.count
        } else if collectionView == reloadCollectionVIew {
            return getMoviesForSelectedCategory().count
        } else {
            return categories.count
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
        if collectionView == categoryCollectionView {//MARK: categoryCollectionView
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
        }else if collectionView == reloadCollectionVIew{ //MARK: reloadCollectionVIew
            
            if !getMoviesForSelectedCategory().isEmpty{
                let movie = getMoviesForSelectedCategory()[indexPath.row]
                
                let secondVC = storyboard?.instantiateViewController(withIdentifier: "MovieDetailsViewController") as! MovieDetailsViewController
                secondVC.movieID = movie.id
                secondVC.movieTitle = movie.title
                
                secondVC.descriptionMovie = movie.overview
                secondVC.releasedate = movie.releaseDate
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
        }else if collectionView == trendingCollectionView{
            if !viewModel.trendingMovies.isEmpty {
                let movie = viewModel.trendingMovies[indexPath.row]
                pushToMovieDetails(with: movie)
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
    private func pushToMovieDetails(with movie: Movie) {
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "MovieDetailsViewController") as! MovieDetailsViewController
        secondVC.movieID = movie.id
        secondVC.movieTitle = movie.title
        secondVC.descriptionMovie = movie.overview
        secondVC.releasedate = movie.releaseDate
        
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

// MARK: - Private Methods

private extension HomeViewController{
    func loadImage(from path: String?, completion: @escaping (UIImage?) -> Void) {
        guard let path = path, let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
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
