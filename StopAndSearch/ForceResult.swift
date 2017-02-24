//
//  ForceResult.swift
//  StopAndSearch
//
//  Created by edit on 24/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Foundation
import Gloss

class ForceResult {
  
  var id: String?
  var name: String?
  
  required init?(json: JSON) {
    self.id  = "id" <~~ json
    self.name  = "name" <~~ json
    self.id = self.id?.removingPercentEncoding
    self.name  =  self.name?.removingPercentEncoding
  }
  
}
