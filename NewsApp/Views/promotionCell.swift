//
//  promotionCell.swift
//  NewsApp
//
//  Created by Roi Kedarya on 05/07/2021.
//

import Foundation
import UIKit

class promotionCell: UITableViewCell {
    
    @IBOutlet weak var promotionRightLabel: UILabel!
    @IBOutlet weak var promotionLeftLabel: UILabel!
    @IBOutlet weak var view: UIView!
    
    let link = URL.init(string: "https://www.tipranks.com/")
    
}
