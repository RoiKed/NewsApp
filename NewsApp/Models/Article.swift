//
//  Article.swift
//  NewsApp
//
//  Created by Roi Kedarya on 04/07/2021.
//

import Foundation

struct ArticleList: Decodable {
    let data: [Article]
}

struct Article: Decodable {
    let title: String
    let date: String
    let link: String
    let description: String
    let author: Author
    let image: Image
}

struct Image: Decodable {
    let src: String?
}

struct Author: Decodable {
    let name: String
    let image: Image
}
