//
//  GraphsViewController.swift
//  StopAndSearch
//
//  Created by edit on 18/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit
import Charts

class BarGraphViewController: UIViewController, ChartViewDelegate {

  var barChartView: BarChartView?
  var graphArray = [[SearchResult]]()
  var tabBarHeight: CGFloat?
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Bar Chart"
    tabBarHeight = tabBarController!.tabBar.frame.size.height
    barChartInit()

      if let d = (tabBarController as! GraphsTabBarController).data {
        for cat in Categories.categories {
          //loop through all categories
          let filteredByCat = d.filter {$0.title == cat.category    }
          if !filteredByCat.isEmpty {
            graphArray.append(filteredByCat)
          }
        }
      }     
     setChart()
  }
  
  func barChartInit() {
    barChartView = BarChartView(frame: CGRect(x: 0, y: 60, width: self.view.frame.size.width, height: self.view.frame.size.height - (60 + tabBarHeight!)))
    barChartView!.backgroundColor = .flatWhite
    barChartView!.isUserInteractionEnabled = true
    self.view.addSubview(barChartView!)
  }
  
 func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) { print (entry)}
  
  func setChart() {
       //initialise dataEntries array
    barChartView!.noDataText = "You need to provide data for the chart."
    var dataEntries: [BarChartDataEntry] = []
    for (i,catArray) in graphArray.enumerated() {
      let dataEntry = BarChartDataEntry( x : Double(i), y: Double (catArray.count))
      dataEntries.append(dataEntry)
    }
    
    let chartDataSet = BarChartDataSet(values: dataEntries, label: nil)
    chartDataSet.form = .none
    let chartData = BarChartData(dataSet: chartDataSet)
    barChartView!.data = chartData
    
    if view.traitCollection.verticalSizeClass == .regular {
      let labels  = graphArray.map { $0[0].title!}
      barChartView!.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
      barChartView!.xAxis.labelCount = graphArray.count
      barChartView!.xAxis.labelPosition = .bottom
     // let tHeight = tabBarController?.view.frame.size.height
      barChartView!.extraBottomOffset = 110
      barChartView!.xAxis.labelRotationAngle = -90
    } else {
   
      barChartView!.xAxis.drawLabelsEnabled = false
       //  barChartView!.extraBottomOffset = 20
    }
    
    barChartView!.xAxis.granularityEnabled = true
    barChartView!.xAxis.granularity = 1
    barChartView!.xAxis.drawGridLinesEnabled = false
    barChartView!.extraTopOffset = 60
    barChartView!.leftAxis.enabled = true
    barChartView!.pinchZoomEnabled = true
    barChartView!.scaleYEnabled = true
    barChartView!.scaleXEnabled = true
   // barChartView!.highlighter = nil
    barChartView!.doubleTapToZoomEnabled = false
    barChartView!.chartDescription?.text = ""
    chartDataSet.colors =  graphArray.map{$0[0].color!}
      barChartView!.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    
    print ("orientation change")
    barChartView?.removeFromSuperview()
    barChartInit()
    setChart()
  
  }
}
