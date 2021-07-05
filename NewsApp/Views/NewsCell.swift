//
//  NewsCell.swift
//  NewsApp
//
//  Created by Roi Kedarya on 04/07/2021.
//

import UIKit


class NewsCell: UITableViewCell {
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    public func update(_ title: String, _ subTitle: String, _ mainImageUrl: URL?, _ authorImageUrl: URL?, _ date: String, _ authorName: String) {
        self.title.text = title
        self.subTitle.text = subTitle
        if let mainImageUrl = mainImageUrl {
            loadImageFor(mainImageUrl, for: "main")
        }
        setAuthorImage(with: authorImageUrl)
        self.details.text =  authorName + "   |   " + date
    }
    
    private func setAuthorImage(with url: URL?) {
        if let authorImageUrl = url {
            loadImageFor(authorImageUrl, for: "author")
            self.authorImage.layer.masksToBounds = false
            self.authorImage.layer.borderWidth = 1.0
            self.authorImage.layer.borderColor = UIColor.black.cgColor
            self.authorImage.layer.cornerRadius = self.authorImage.frame.height/2
            self.authorImage.clipsToBounds = true
        }
    }
    
    private func loadImageFor(_ url: URL, for type:String) {
        WebService.shared.getImageFromUrl(url) { [weak self] (data, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                self?.loadImageFrom(data,type)
            }
        }
    }
    
    private func loadImageFrom(_ data: Data, _ type:String) {
        DispatchQueue.global().async { [weak self] in
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if type == "author", let imageView = self?.authorImage {
                        imageView.image = image
                    } else {
                        self?.mainImage.image = image
                    }
                }
            }
        }
    }
    
    override func layoutSubviews() {
          super.layoutSubviews()
          self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0))
     }
}
