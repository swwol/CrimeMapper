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
  var data : [SearchResult]?
let defaults = UserDefaults.standard
var startMonth: Int = 0
var startYear: Int = 0
var endMonth: Int = 0
var endYear: Int = 0
var dates: [String]?
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      print ("loaded line graph view")
        readData()
        lineChartInit() // just makes and resizes charet object
  
      // put data into graph array
      if let d = data {
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
  
  func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
   
    let set = highlight.dataSetIndex
    let setColor  = lineChartView?.data?.dataSets[set].colors[0]
    let title  = lineChartView?.data?.dataSets[set].label
   //let entryIndex = lineChartView?.data?.dataSets[0].entryIndex(entry: entry)
 //  let segColor = setColor!
   let compSegColor = setColor!
    
    let marker:BalloonMarker = BalloonMarker(title: title, color: compSegColor , font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.init(contrastingBlackOrWhiteColorOn: compSegColor, isFlat: true) , insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0))
    marker.minimumSize = CGSize(width: 75, height: 35)
    
    lineChartView?.marker  = marker
    
    
    
  }
  
  
  func setChart() {
    
    // generate an array of dates for labelling x axis
    
    dates  = [String]()
    var thisDate = MonthYear ( month: startMonth, year: startYear)
    repeat {
      dates?.append(thisDate.getDateAsString())
     thisDate =  thisDate.increment()
    } while (thisDate <= MonthYear(month: endMonth, year: endYear))
  
    
    
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
         set.setColor(catResultArray[0].color!)
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
 
   
    lineChartView?.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates!)
    lineChartView!.xAxis.labelCount = dates!.count
    lineChartView?.xAxis.labelPosition = .bottom
    lineChartView?.extraBottomOffset = 40
    lineChartView?.xAxis.labelRotationAngle = -90
    lineChartView?.xAxis.granularityEnabled = true
    lineChartView?.xAxis.granularity = 1
  }

  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  func lineChartInit() {
    
    
    lineChartView = LineChartView(frame: CGRect(x: 0, y: 0 , width: self.view.frame.size.width, height: self.view.frame.size.height))
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
