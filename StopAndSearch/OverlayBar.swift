//
//  OverlayBar.swift
//  StopAndSearch
//
//  Created by edit on 15/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit


class OverlayBar: UIView {


  @IBOutlet weak var sLabel: UILabel!
  @IBOutlet weak var bgview: UIView!
  @IBOutlet weak var startDate: UILabel!
  @IBOutlet weak var endDate: UILabel!
  @IBOutlet weak var areaID: UILabel!
  @IBOutlet weak var area: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    print ("this is my view")
    self.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
  }
  
  class func instanceFromNib() -> UIView {
    return UINib(nibName: "OverlayBar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
  }
}
  

  
  
