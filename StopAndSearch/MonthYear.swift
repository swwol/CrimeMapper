//
//  MonthYear.swift
//  StopAndSearch
//
//  Created by edit on 21/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Foundation

struct MonthYear {
  let month: Int
  let year: Int
  var monthName: String {
    return "\(Months.months[month])"
  }
  var yearAsString: String {
    return "\(year)"
  }
  var dateFormattedForApiSearch: String {
      let paddedMonth  = String(format: "%02d", (month+1))
      return yearAsString+"-"+paddedMonth
  }
  
  var dateAsString: String {
    return "\(monthName) \(year)"
  }
  
}
