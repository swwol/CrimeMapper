//
//  LineGraphViewController.swift
//  StopAndSearch
//
//  Created by edit on 20/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit
import Charts
class LineGraphViewController: UIViewController, ChartViewDelegate {
  
var lineChartView: LineChartView?
var catResultArrays = [[SearchResult]]()
var tabBarHeight: CGFloat?
let defaults = UserDefaults.standard
var startMonth: Int = 0
var startYear: Int = 0
var endMonth: Int = 0
var endYear: Int = 0
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      print ("loaded line graph view")
        readData()
      
      
     
        tabBarHeight = tabBarController!.tabBar.frame.size.height
        lineChartInit() // just makes and resizes charet object
      
      // put data into graph array
      if let d = (tabBarController as! GraphsTabBarController).data {
        for cat in Categories.categories {
          //loop through all categories
          let filteredByCat = d.filter {$0.title == cat.category    }
          if !filteredByCat.isEmpty {
            catResultArrays.append(filteredByCat)
          }
        }
      }
      // so we should now have 2D array of SearchResults
      
      // [Categoery1 results],
      // [Category2 results].
      // [Category3 results],
      // ... 
      
      setChart()
  
  }
  
  override func viewWillAppear(_ animated: Bool) {
    readData()
  }
  
  
  func setChart() {
    
    print ("setting chart")
    
    var lineChartDataSets = [LineChartDataSet]()
    
    // iterate for each category in graphArray
    for catResultArray in catResultArrays {
      print ("iterating through catResultArray")
      var dateIndex: Double = 0
      var dateIncrement = MonthYear(month: startMonth, year: startYear)
      var chartDataEntriesForCat: [ChartDataEntry]  = [ChartDataEntry]()
      repeat {
        print ("in repear loop")
        chartDataEntriesForCat.append(ChartDataEntry(x: dateIndex,
                                                     y: Double(catResultArray.filter{$0.month == dateIncrement.getDateFormattedForApiSearch()}.count)))
        
        dateIndex += 1.0
        print(dateIndex)
        dateIncrement = dateIncrement.increment()
      } while (dateIncrement <= MonthYear(month: endMonth, year: endYear))
      
      // now have an array of ChartDataEntries for this category..
      
      if !chartDataEntriesForCat.isEmpty && !catResultArray.isEmpty {
        //if there is something in this category both arrays should be non empty int theory
         let set = LineChartDataSet(values: chartDataEntriesForCat, label: catResultArray[0].title!)
         set.axisDependency = .left
         set.setColor(catResultArray[0].color!.withAlphaComponent(0.5))
         set.setCircleColor(catResultArray[0].color!)
         set.lineWidth = 2
         set.circleRadius = 6.0 // the radius of the node circle
         set.fillAlpha = 65 / 255.0
         set.fillColor = catResultArray[0].color!
         set.highlightColor = UIColor.white
         set.drawCircleHoleEnabled = true
         lineChartDataSets.append(set)
      }
    }
    
    let data = LineChartData(dataSets: lineChartDataSets)
    data.setValueTextColor(.white)
    self.lineChartView?.data = data
  }

  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  func lineChartInit() {
    var yOffset: CGFloat
    if view.traitCollection.verticalSizeClass == .compact {
      yOffset = 100 } else {
      yOffset = 60
    }
    
    lineChartView = LineChartView(frame: CGRect(x: 0, y: yOffset, width: self.view.frame.size.width, height: self.view.frame.size.height - (yOffset + tabBarHeight!)))
    lineChartView!.backgroundColor = .flatWhite
    lineChartView!.isUserInteractionEnabled = true
    lineChartView!.delegate = self
    lineChartView!.chartDescription?.text = "Tap node for details"
    // 3
    lineChartView!.chartDescription?.textColor = UIColor.white
    lineChartView!.gridBackgroundColor = UIColor.darkGray
    // 4
    lineChartView!.noDataText = "No data provided"
    
    
    self.view.addSubview(lineChartView!)
  }
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    
    print ("orientation change")
    lineChartView?.removeFromSuperview()
    lineChartInit()
    setChart()
    
  }

  func readData() {
    startMonth  = defaults.integer(forKey: "startMonth")
    startYear  = defaults.integer(forKey: "startYear")
    endMonth  = defaults.integer(forKey: "endMonth")
    endYear  = defaults.integer(forKey: "endYear")
  }
  
  
}
