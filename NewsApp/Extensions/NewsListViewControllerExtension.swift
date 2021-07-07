//
//  NewsListViewControllerExtension.swift
//  NewsApp
//
//  Created by Roi Kedarya on 05/07/2021.
//

import Foundation
import UIKit
import SafariServices

extension NewsListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchString = searchBar.text, searchString.isEmpty == false {
            self.articleListVM.articles.removeAll()
            self.spinner.startAnimating()
            WebService.shared.getArticles(for: searchString, isFirstLoad: true) { [weak self] articles, responce, error in
                if let error = error {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self?.spinner.stopAnimating()
                        return
                    }
                }
                guard let response = responce as? HTTPURLResponse else { return }
                    
                if let articles = articles {
                    if articles.count < 22 || response.statusCode == 404 {
                        self?.allowPaging = false
                    }
                    self?.articleListVM.articles.append(contentsOf: articles)
                }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.spinner.stopAnimating()
                    if let numberOfItems = self?.articleListVM.articles.count, numberOfItems > 0 {
                        let firstIndex = IndexPath(row: 0, section: 0)
                        self?.tableView.scrollToRow(at:firstIndex , at: .top, animated: true)
                    }
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
        if isPromotionCell(indexPath.row) {
            guard let promotionCell = tableView.dequeueReusableCell(withIdentifier: "promotionCell", for: indexPath) as? promotionCell else {
                fatalError("News cell not found")
            }
            return promotionCell
        } else {
            guard let newsCell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as? NewsCell else {
                fatalError("News cell not found")
            }
            let articleViewModel = articleListVM.articleAtIndex(indexPath.row)
            newsCell.update(articleViewModel.title, articleViewModel.subTitle, articleViewModel.articleImageUrl, articleViewModel.authorImageUrl, articleViewModel.date, articleViewModel.authorName)
            return newsCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = isPromotionCell(indexPath.row) ? 100: 400
        return height
    }
    
    /* since articles starts at index number 0 and
     every 3rd 13th.. 23rd .. cells are promotion we check for % 10
     */
    func isPromotionCell(_ index: Int) -> Bool {
        return  index % 10 == 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPromotionCell(indexPath.row) {
            //open the url in the device's web browser
            guard let cell = tableView.cellForRow(at: indexPath) as? promotionCell,
                  let url = cell.link else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } else {
            print("selected cell at index \(indexPath.row)")
            //open the url internally on a new webViewController
            if let url = URL(string: self.articleListVM.updatedArticles[indexPath.row].link) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                config.barCollapsingEnabled = true
                let safariViewController = SFSafariViewController(url: url, configuration: config)
                self.navigationController?.present(safariViewController, animated: true)
            }
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if didScrollToLastItem(scrollView) && allowPaging == true {
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
