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
  var messageLabel: UILabel
  
  init(message: String, size: String = "large") {
   
    if size == "large" {
      strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 250, height: 50))
      messageLabel =  UILabel(frame: CGRect(x:50,y:35, width: 200, height: 50))
      super.init(frame: CGRect(x:0, y:0, width: 250, height: 100))
    } else {
      strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 250, height: 50))
      messageLabel =  UILabel(frame: CGRect(x:50,y:35, width: 200, height: 50))
      super.init(frame: CGRect(x:0, y:0, width: 250, height: 50))
      
    }
  self.layer.cornerRadius = 15
  self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
  let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
  let blurEffectView = UIVisualEffectView(effect: blurEffect)
  blurEffectView.layer.cornerRadius = 15
  blurEffectView.clipsToBounds = true
  blurEffectView.frame = self.bounds
  self.addSubview(blurEffectView)

    
    
  //messageLabel.text="testing:"
  strLabel.text = message
  strLabel.textColor = UIColor.darkGray
  messageLabel.textColor = UIColor.darkGray
  messageLabel.font = messageLabel.font.withSize(10)
  addSubview(strLabel)
  addSubview(messageLabel)
  activityIndicator.frame = CGRect(x: frame.origin.x + 5  , y: frame.midY-25, width: 50, height: 50)
  activityIndicator.startAnimating()
  addSubview(activityIndicator)

  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
}
