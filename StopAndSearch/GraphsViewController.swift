//
//  GraphsViewController.swift
//  StopAndSearch
//
//  Created by edit on 18/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit
import Charts

class GraphsViewController: UIViewController {

  @IBOutlet weak var barChartView: BarChartView!
  
  
  var data: [SearchResult]?
  var graphArray = [[SearchResult]]()
    override func viewDidLoad() {
        super.viewDidLoad()

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func setChart() {
    barChartView.noDataText = "You need to provide data for the chart."
    var dataEntries: [BarChartDataEntry] = []
    
    for (i,catArray) in graphArray.enumerated() {
      let dataEntry = BarChartDataEntry( x : Double(i), y: Double (catArray.count))
      dataEntries.append(dataEntry)
    }
 
    let chartDataSet = BarChartDataSet(values: dataEntries, label: "number in categories")
    chartDataSet.colors =  graphArray.map{$0[0].color!}
    let chartData = BarChartData(dataSet: chartDataSet)
    barChartView.data = chartData
  }
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
