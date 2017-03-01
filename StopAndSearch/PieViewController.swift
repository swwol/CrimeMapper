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
          let filteredByCat = d.filter {$0.title == cat.category }
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
    for catArray in graphArray {
  let dataEntry = PieChartDataEntry(value: Double(catArray.count), label: catArray[0].title)
      dataEntries.append(dataEntry)
    }
    let pieChartDataSet = PieChartDataSet(values: dataEntries, label: nil)
    pieChartDataSet.colors =  graphArray.map{$0[0].color!}
    pieChartView?.drawEntryLabelsEnabled = false
    let pieChartData = PieChartData(dataSet: pieChartDataSet)
   pieChartView?.usePercentValuesEnabled = true
  pieChartData.setValueFormatter(DigitValueFormatter())
    
    
    
    pieChartView?.data = pieChartData
   
 
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
  
   func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    
    // get color of selected segment
    
    let entryIndex = pieChartView?.data?.dataSets[0].entryIndex(entry: entry)
    let segColor = pieChartView?.data?.dataSets[0].colors[entryIndex!]
    let compSegColor = UIColor.init(complementaryFlatColorOf: segColor!)
    
    let marker:BalloonMarker = BalloonMarker(color: compSegColor , font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.init(contrastingBlackOrWhiteColorOn: compSegColor, isFlat: true) , insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0))
    marker.minimumSize = CGSize(width: 75, height: 35)

       pieChartView?.marker  = marker
  
  }
  
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    
    print ("orientation change")
    pieChartView?.removeFromSuperview()
    pieChartInit()
    setChart()
    
  }
}
