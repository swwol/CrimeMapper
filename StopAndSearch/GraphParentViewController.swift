//
//  GraphParentViewController.swift
//  StopAndSearch
//
//  Created by edit on 28/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class GraphParentViewController: UIViewController, InitialisesExtendedNavBar {
  
  var extendedNavBarColor = UIColor.flatGray.withAlphaComponent(0.33)
  var extendedNavBarMessage =  "touch cluster of pin for info"
  var extendedNavBarShouldShowDate = true
  var extendedNavBarFontSize: CGFloat  = 12
  var extendedNavBarFontColor = UIColor.flatBlack
  var extendedNavBarIsHidden = true
  //

  
  enum TabIndex : Int {
    case barchart = 0
    case piechart = 1
    case linegraph = 2
  }
  
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var regoinLabel: UILabel!
  @IBOutlet weak var seg: UISegmentedControl!
  @IBOutlet weak var contentView: UIView!
  
  var currentViewController: UIViewController?
  var data: [SearchResult]?
  
  lazy var emptyVC: UIViewController? = {
    let emptyVC = self.storyboard?.instantiateViewController(withIdentifier: "emptyVC")
    return emptyVC
  }()
  
  lazy var barVC: UIViewController? = {
    let barVC = self.storyboard?.instantiateViewController(withIdentifier: "barVC")
    return barVC
  }()
  
  lazy var pieVC : UIViewController? = {
    let pieVC = self.storyboard?.instantiateViewController(withIdentifier: "pieVC")
    return pieVC
  }()
  
  lazy var lineVC : UIViewController? = {
    let lineVC = self.storyboard?.instantiateViewController(withIdentifier: "lineVC")
    return lineVC
  }()

  
  
  // MARK: - View Controller Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    seg.selectedSegmentIndex = TabIndex.barchart.rawValue
    displayCurrentTab(TabIndex.barchart.rawValue)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if let currentViewController = currentViewController {
      currentViewController.viewWillDisappear(animated)
    }
  }
 
  // MARK: - Switching Tabs Functions
  @IBAction func switchTabs(_ sender: UISegmentedControl) {
    self.currentViewController!.view.removeFromSuperview()
    self.currentViewController!.removeFromParentViewController()
    
    displayCurrentTab(sender.selectedSegmentIndex)
  }
  
  func displayCurrentTab(_ tabIndex: Int){
    if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
      
      self.addChildViewController(vc)
      vc.didMove(toParentViewController: self)
      
      vc.view.frame = self.contentView.bounds
      self.contentView.addSubview(vc.view)
      self.currentViewController = vc
    }
  }
  
  func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
    var vc: UIViewController?
    
    guard (!data!.isEmpty) else {
      print ("nothing here")
      return emptyVC
    }
    
    
    switch index {
    case TabIndex.barchart.rawValue :
      vc = barVC
     (vc as! BarGraphViewController).data = self.data
    case TabIndex.piechart.rawValue :
      vc = pieVC
      (vc as! PieViewController).data = self.data
    case TabIndex.linegraph.rawValue :
      vc = lineVC
      (vc as! LineGraphViewController).data = self.data
    default:
      return nil
    }
   
    return vc
  }
}

