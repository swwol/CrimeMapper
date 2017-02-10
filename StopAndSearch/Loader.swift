//
//  Loader.swift
//  StopAndSearch
//
//  Created by edit on 09/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class Loader: UIView {


  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  var strLabel : UILabel
  
  init(message: String) {
   
  
  strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 250, height: 50))
  super.init(frame: CGRect(x:0, y:0, width: 250, height: 50))
  self.layer.cornerRadius = 15
  self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
  let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
  let blurEffectView = UIVisualEffectView(effect: blurEffect)
  blurEffectView.layer.cornerRadius = 15
  blurEffectView.clipsToBounds = true
  blurEffectView.frame = self.bounds
  self.addSubview(blurEffectView)

    
    
    
  strLabel.text = message
  strLabel.textColor = UIColor.darkGray
  addSubview(strLabel)
  activityIndicator.frame = CGRect(x: frame.origin.x + 5  , y: frame.midY-25, width: 50, height: 50)
  activityIndicator.startAnimating()
  addSubview(activityIndicator)

  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
