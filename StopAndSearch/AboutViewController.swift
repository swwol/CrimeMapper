//
//  AboutViewController.swift
//  StopAndSearch
//
//  Created by edit on 03/03/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, InitialisesExtendedNavBar {
  
  //propertieas to initialise xnavbar with if vc is navigated to
  
  var extendedNavBarColor = UIColor.flatGray.withAlphaComponent(0.33)
  var extendedNavBarMessage =  "touch cluster of pin for info"
  var extendedNavBarShouldShowDate = true
  var extendedNavBarFontSize: CGFloat  = 12
  var extendedNavBarFontColor = UIColor.flatBlack
  var extendedNavBarIsHidden = true
  //
  


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

 
}
