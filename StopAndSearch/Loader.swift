//
//  Loader.swift
//  StopAndSearch
//
//  Created by edit on 09/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class Loader: UIView {


  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
  var strLabel : UILabel
  
  init(message: String) {
   
  
  strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
  super.init(frame: CGRect(x:0, y:0, width: 180, height: 50))
  self.layer.cornerRadius = 15
  self.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
  strLabel.text = message
  strLabel.textColor = UIColor.white
  addSubview(strLabel)
  activityIndicator.frame = CGRect(x: frame.origin.x + 5  , y: frame.midY-25, width: 50, height: 50)
  activityIndicator.startAnimating()
  addSubview(activityIndicator)
 // applyPlainShadow(view: self)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func applyPlainShadow(view: UIView) {
    let l = view.layer
    
    l.shadowColor = UIColor.black.cgColor
    l.shadowOffset = CGSize(width: 2, height: 2)
    l.shadowOpacity = 0.2
    l.shadowRadius = 3
  }
}
