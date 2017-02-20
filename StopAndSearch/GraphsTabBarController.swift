//
//  GraphsTabBarController.swift
//  StopAndSearch
//
//  Created by edit on 19/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class GraphsTabBarController: UITabBarController {
  
  var data: [SearchResult]?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      self.tabBar.barTintColor = .flatMintDark

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

 

}
