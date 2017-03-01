//
//  PieViewController.swift
//  StopAndSearch
//
//  Created by edit on 20/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit
import Charts


class PieViewController: UIViewController, ChartViewDelegate {
  
  var pieChartView: PieChartView?
  var graphArray = [[SearchResult]]()
  var data: [SearchResult]?

    override func viewDidLoad() {
      
      super.viewDidLoad()
      
   
      
      pieChartInit()
      
      if let d = data {
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
  

  override func viewWillAppear(_ animated: Bool) {
  
  }
  
  func setChart() {
    pieChartView!.noDataText = "You need to provide data for the chart."
    var dataEntries: [ChartDataEntry] = []
    for (i,catArray) in graphArray.enumerated() {
  let dataEntry = PieChartDataEntry(value: Double(catArray.count), label: catArray[0].title)
     let dataEntryWithSliceIndex =  dataEntry as ChartDataEntry
       dataEntryWithSliceIndex.x  = Double(i)
      // let dataEntry =     ChartDataEntry(x: Double(i), y:  Double(catArray.count), data:  catArray[0].title as AnyObject? )
      dataEntries.append(dataEntryWithSliceIndex)
    }
    let pieChartDataSet = PieChartDataSet(values: dataEntries, label: nil)
    pieChartDataSet.colors =  graphArray.map{$0[0].color!}
    pieChartView?.drawEntryLabelsEnabled = false
    let pieChartData = PieChartData(dataSet: pieChartDataSet)
    pieChartView?.data = pieChartData
  
   // pieChartDataSet.form = .none
    pieChartView!.chartDescription?.text = ""
    if view.traitCollection.verticalSizeClass == .compact {
    
    pieChartView!.legend.enabled = false
    
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func pieChartInit() {
         
    pieChartView = PieChartView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height ))
    pieChartView!.backgroundColor = .flatWhite
    pieChartView!.isUserInteractionEnabled = true
    pieChartView!.delegate = self
    self.view.addSubview(pieChartView!)
  }
  
   func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) { print (entry)}
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    
    print ("orientation change")
    pieChartView?.removeFromSuperview()
    pieChartInit()
    setChart()
    
  }
}
