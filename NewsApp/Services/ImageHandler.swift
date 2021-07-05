//
//  ImageHandler.swift
//  NewsApp
//
//  Created by Roi Kedarya on 01/07/2021.
//

import Foundation
import UIKit

class ImageHandler {
    
    private var images = NSCache<NSString, NSData>()
    static let shared: ImageHandler = ImageHandler()

    private init() {}
    
    func getImageFromUrl(_ urlString: String, completion: @escaping (UIImage?) -> ()) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func getImageFromUrl(_ urlString: String, completion: @escaping (Data?, Error?) -> ()) {
        //check first if exist in cache
        if let imageData = images.object(forKey: urlString as NSString) {
              print("using cached images")
              completion(imageData as Data, nil)
              return
        }
        
        //download the image and store it to cache
        guard let url = URL(string: urlString) else {
            completion(nil,NetworkManagerError.invalidUrl)
            return
        }
        URLSession.shared.downloadTask(with: url) { localUrl, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            guard let localUrl = localUrl else {
                completion(nil, NetworkManagerError.badLocalUrl)
                return
            }
            
            do {
                let data = try Data(contentsOf: localUrl)
                self.images.setObject(data as NSData, forKey: urlString as NSString)
                print("downloaded new image")
                completion(data, nil)
            } catch let error {
                completion(nil, error)
              }
            }.resume()
        }
}


