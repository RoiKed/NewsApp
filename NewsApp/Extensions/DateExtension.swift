//
//  DateExtension.swift
//  NewsApp
//
//  Created by Roi Kedarya on 04/07/2021.
//

import Foundation
import UIKit

extension Date {
    func compare(_ stringDate: String) -> String {
        var retVal: String = ""
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: stringDate) {
            let delta = self.timeIntervalSince(date)
            let minute: Double = 60
            let hour: Double = 60 * minute
            let day: Double = 24 * hour
            let week: Double = 7 * day
            let minutesDiff = delta / 60.0
            let hoursDiff = minutesDiff / 60.0
            let daysDiff = hoursDiff / 24.0
            
            if delta < 5 * minute {
                retVal = "Now"
            } else if delta < hour {
                retVal = "\(Int(minutesDiff)) minutes ago"
            } else if delta < day {
                retVal = "\(Int(hoursDiff)) hours ago"
            } else if delta < week {
                retVal = "\(Int(daysDiff)) days ago"
            } else {
                dateFormatter.dateFormat = "dd-MM-yyyy"
                    retVal = dateFormatter.string(from: date)
            }
        }
        return retVal
    }
}
