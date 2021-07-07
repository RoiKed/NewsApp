//
//  WebService.swift
//  NewsApp
//
//  Created by Roi Kedarya on 04/07/2021.
//

import Foundation

enum NetworkManagerError: Error {
    case badResponse(URLResponse?)
    case parsingFailed
    case invalidUrl
    case badLocalUrl
}


class WebService {
    
    private var images = NSCache<NSString, NSData>()
    public let numberOfItemsPerPage = 20
    private lazy var tipRanksUrlComponents: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.tipranks.com"
        components.path = "/api/news/posts"
        components.queryItems = [
                URLQueryItem(name: "per_page", value: String(numberOfItemsPerPage)),
                URLQueryItem(name: "page", value: "1")
            ]
        return components
    }()
    
    static let shared: WebService = WebService()
    private init() {}
    
    private func updatePageNumber(shouldReset:Bool?) {
        if let pageQueryItem = tipRanksUrlComponents.queryItems?[1],
        var queryValue = pageQueryItem.value,
           var pageQueryItemValue = Int(queryValue) {
            pageQueryItemValue = shouldReset == true ? 1 : pageQueryItemValue + 1
            queryValue = String(pageQueryItemValue)
            tipRanksUrlComponents.queryItems![1].value = queryValue
            print("updated page to \(queryValue)")
        }
    }
    
    private func addSearchPhrase(_ searchPhrase: String) {
        if let queryItems = tipRanksUrlComponents.queryItems {
            let queryItem = URLQueryItem(name: "search", value: searchPhrase)
           if queryItems.count == 3 {
            //update last quary to the new search phrase
            tipRanksUrlComponents.queryItems![2] = queryItem
           } else {
            // add new URLQueryItem to queryItems
            tipRanksUrlComponents.queryItems!.append(queryItem)
           }
        }
    }
    
    func getArticles(for search: String, isFirstLoad: Bool, completion: @escaping ([Article]?, URLResponse?, Error?) -> ()) {
        addSearchPhrase(search)
        updatePageNumber(shouldReset: true)
        getArticles(isFirstLoad: isFirstLoad, completion: completion)
    }
    
    func getArticles(isFirstLoad: Bool, completion: @escaping ([Article]?, URLResponse?,  Error?) -> ()) {
        if isFirstLoad == false {
            updatePageNumber(shouldReset: false)
        }
        if let url = tipRanksUrlComponents.url {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(nil,nil,error)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    completion(nil, response, NetworkManagerError.badResponse(response))
                    return
                }
                if let data = data {
                    //parsing the data
                    let articleList = try?  JSONDecoder().decode(ArticleList.self, from: data)
                    if let articleList = articleList {
                        completion(articleList.data, response, nil)
                    } else {
                        completion(nil, response, NetworkManagerError.parsingFailed)
                    }
                }
            }.resume()
        }
    }
    
    func getImageFromUrl(_ url: URL, completion: @escaping (Data?, Error?) -> ()) {
        //check first if exist in cache
        if let imageData = images.object(forKey: url.absoluteString as NSString) {
              completion(imageData as Data, nil)
              return
        }
        
        URLSession.shared.downloadTask(with: url) { localUrl, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(nil, NetworkManagerError.badResponse(response))
                return
            }
            guard let localUrl = localUrl else {
                completion(nil, NetworkManagerError.badLocalUrl)
                return
            }
            
            do {
                let data = try Data(contentsOf: localUrl)
                self.images.setObject(data as NSData, forKey: url.absoluteString as NSString)
                completion(data, nil)
            } catch let error {
                completion(nil, error)
              }
            }.resume()
        }
}
