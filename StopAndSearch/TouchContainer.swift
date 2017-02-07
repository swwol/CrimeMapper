//
//  TouchContainer.swift
//  StopAndSearch
//
//  Created by edit on 02/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

protocol TouchContainerDelegate {
  func touchContainerTouched(_ sender : TouchContainer)
}

class TouchContainer: UIView {
  
  var delegate: TouchContainerDelegate?
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print ("began!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    self.alpha = 0.5
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("ended")
    self.alpha = 1
    delegate?.touchContainerTouched(self)
  }
}
