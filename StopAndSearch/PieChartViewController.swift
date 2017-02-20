//
//  PieChartViewController.swift
//  StopAndSearch
//
//  Created by edit on 20/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit
import Charts

class PieChartViewController: UIViewController {


  
  var pieChartView: PieChartView?
  
  var graphArray = [[SearchResult]]()
  var tabBarHeight: CGFloat?
  override func viewDidLoad() {
    super.viewDidLoad()
    tabBarHeight = tabBarController!.tabBar.frame.size.height
   }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  

}
