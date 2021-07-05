//
//  ArticleViewModel.swift
//  NewsApp
//
//  Created by Roi Kedarya on 04/07/2021.
//

import Foundation
import UIKit

struct ArticleViewModel {
    private let article: Article
    
    init(_ article: Article) {
        self.article = article
    }
}

extension ArticleViewModel {
    var title: String {
        return article.title
    }
    var subTitle: String {
        var description = article.description
        if let index = description.firstIndex(of: ">") {
            let endRange = description.index(after: index)
            description.removeSubrange(description.startIndex ..< endRange)
        }
        return description
    }
    //will change this to present according to specify logic
    var date: String {
        return Date().compare(article.date)
    }
    
    var authorName: String {
        return article.author.name
    }
    
    var authorImageUrl: URL? {
        if let src = article.author.image.src {
            return URL(string: src)
        }
        return nil
    }
    
    var articleImageUrl: URL? {
        if let src = article.image.src {
            return URL(string: src)
        }
        return nil
    }
}

struct ArticleListViewModel {
    var articles: [Article]
    
    init(_ articles: [Article]?) {
        if let articles = articles {
            self.articles = articles
        } else {
            self.articles = [Article]()
        }
    }
    
    var numberOfSections = 1
    
    func numberOfRowsInSection(section: Int) -> Int {
        return articles.count
    }
    
    func articleAtIndex(_ index: Int) -> ArticleViewModel {
        let retVal = ArticleViewModel(articles[index])
        return retVal
    }
}
