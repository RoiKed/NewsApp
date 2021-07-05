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
    
    private var articleListVM = ArticleListViewModel(nil)
    private var lastItemIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
        
    // MARK: - Private Methods
    
    private func setup() {
        setupTable()
        setupSpinner()
        setupSearchBar()
    }
    
    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "newsCell")
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
        searchBarSearchButtonClicked(self.searchBar)
    }
    
    @objc private func removeKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    private func setupSpinner() {
        spinner.hidesWhenStopped = true
        spinner.stopAnimating()
    }
    
    private func loadContent(isFirstLoad: Bool) {
        self.spinner.startAnimating()
        WebService.shared.getArticles(isFirstLoad: isFirstLoad) { [weak self] articles, error in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    return
                }
            }
            if let articles = articles {
                self?.articleListVM.articles.append(contentsOf: articles)
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.spinner.stopAnimating()
            }
        }
    }
}

extension NewsListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchString = searchBar.text, searchString.isEmpty == false {
            self.articleListVM.articles.removeAll()
            self.spinner.startAnimating()
            WebService.shared.getArticles(for: searchString, isFirstLoad: true) { [weak self] articles, error in
                if let error = error {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self?.spinner.stopAnimating()
                        return
                    }
                }
                if let articles = articles {
                    self?.articleListVM.articles.append(contentsOf: articles)
                }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.spinner.stopAnimating()
                }
            }
        }
    }
}

extension NewsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - delegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return articleListVM.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        numberOfRows = articleListVM.numberOfRowsInSection(section: section)
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as? NewsCell else {
            fatalError("News cell not found")
        }
        if indexPath.row > lastItemIndex {
            lastItemIndex = indexPath.row
        }
        let articleViewModel = articleListVM.articleAtIndex(indexPath.row)
        cell.update(articleViewModel.title, articleViewModel.subTitle, articleViewModel.articleImageUrl, articleViewModel.authorImageUrl, articleViewModel.date, articleViewModel.authorName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    /* since articles starts at index number 0 and
     every 3rd 13th.. 23rd .. cells are promotion we check for % 10
     */
    func isPromotionCell(_ index: Int) -> Bool {
        return  index % 10 == 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected cell at index \(indexPath.row)")
        if let url = URL(string: self.articleListVM.articles[indexPath.row].link) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            config.barCollapsingEnabled = true
            let safariViewController = SFSafariViewController(url: url, configuration: config)
            self.navigationController?.present(safariViewController, animated: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if didScrollToLastItem(scrollView) {
            loadContent(isFirstLoad: false)
        }
    }
    
    private func didScrollToLastItem(_ scrollView: UIScrollView) -> Bool {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        return distanceFromBottom < height
    }
}
