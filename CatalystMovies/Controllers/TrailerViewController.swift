//
//  TrailerViewController.swift
//  CatalystMovies
//
//  Created by Mac on 28/02/25.
//

import UIKit
import WebKit

class TrailerViewController: UIViewController {
    
    var trailerURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupWebView()
    }
    
    private func setupWebView() {
        guard let trailerURL = trailerURL, let url = URL(string: trailerURL) else { return }
        
        let webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        webView.load(URLRequest(url: url))
    }
}
