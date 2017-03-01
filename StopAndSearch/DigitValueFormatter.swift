//
//  DigitValueFormatter.swift
//  StopAndSearch
//
//  Created by edit on 01/03/2017.
//  Copyright © 2017 edit. All rights reserved.
//


import Foundation
import Charts

class DigitValueFormatter : NSObject, IValueFormatter {
  
  func stringForValue(_ value: Double,
                      entry: ChartDataEntry,
                      dataSetIndex: Int,
                      viewPortHandler: ViewPortHandler?) -> String {
   let valueTwoPlaces = String(format: "%.2f", value)
    return "\(valueTwoPlaces)%"
  }
}
