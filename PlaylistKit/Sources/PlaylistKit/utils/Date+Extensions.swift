//
//  Date+Extensions.swift
//  
//
//  Created by Max Baumbach on 07/12/2019.
//

import Foundation

extension Date {
    
    func isInSameYear(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let dateYear = calendar.component(.year, from: self)
        return year == dateYear
    }
    
}
