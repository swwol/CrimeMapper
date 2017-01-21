//
//  Address.swift
//  StopAndSearch
//
//  Created by edit on 20/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Foundation

struct Address {
  
  var building: String?
  var street: String?
  var city: String?
  var postcode: String?
  var fullAddress : String? {
    
    if building == nil && street == nil && city == nil && postcode == nil {
      return nil
    }
    
    var address = ""
    address  = address + (building ?? "")
    
    if let s = street {
    address = addStringOrSpacedString(firstString: address, secondString: s)
    }
    
    if let c = city {
    address = addStringOrSpacedString(firstString: address, secondString: c)
    }
    
    if let p = postcode {
      address = addStringOrSpacedString(firstString: address, secondString: p)
    }
    return address
  }
  
  func addStringOrSpacedString (firstString: String, secondString: String) -> String {
    var s: String
    if   firstString != "" {
      s = firstString + " " + secondString
    } else {
      s = secondString
    }
    return s
  }
}
