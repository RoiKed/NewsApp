//
//  NewsListViewController.swift
//  NewsApp
//
//  Created by Roi Kedarya on 04/07/2021.
//

import Foundation
import UIKit
import SafariServices

class NewsListViewController: UIViewController {
    
    // MARK: - properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var articleListVM = ArticleListViewModel(nil)
    var allowPaging = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
        
    // MARK: - Private Methods
    
    private func setup() {
        setupSpinner()
        setupTable()
        setupSearchBar()
    }
    
    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "newsCell")
        tableView.register(UINib(nibName: "promotionCell", bundle: nil), forCellReuseIdentifier: "promotionCell")
        tableView.separatorStyle = .none
        loadContent(isFirstLoad: true)
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "search"
        searchBar.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(removeKeyboard))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
        self.navigationItem.title = "News        |"
        let rightBarButtonItem = UIBarButtonItem(customView:searchBar)
        let searchButton = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(search))
        self.navigationItem.rightBarButtonItems = [searchButton, rightBarButtonItem]
    }
    
    @objc private func search() {
        self.allowPaging = true
        searchBarSearchButtonClicked(self.searchBar)
    }
    
    @objc private func removeKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    private func setupSpinner() {
        spinner.hidesWhenStopped = true
        spinner.stopAnimating()
    }
    
    internal func loadContent(isFirstLoad: Bool) {
        self.spinner.startAnimating()
        WebService.shared.getArticles(isFirstLoad: isFirstLoad) { [weak self] articles, responce,error in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    return
                }
            }
            guard let responce = responce as? HTTPURLResponse else { return }
            if let articles = articles {
                self?.articleListVM.articles.append(contentsOf: articles)
                let numberOfItemsPerPage = WebService.shared.numberOfItemsPerPage
                if articles.count < numberOfItemsPerPage || responce.statusCode == 404 {
                    self?.allowPaging = false
                }
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.spinner.stopAnimating()
            }
        }
    }
}

