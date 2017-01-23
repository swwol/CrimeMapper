//
//  Address.swift
//  StopAndSearch
//
//  Created by edit on 20/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Foundation
import Contacts


class Address {
  

  var street: String?
  var city: String?
  var postcode: String?
 
  
  func encodedAddress() -> CNMutablePostalAddress  {

    let address = CNMutablePostalAddress()
    
    if let s = street {
      address.street = s
    }
    if let c = city {
      address.city = c
    }
    if let p = postcode {
      address.postalCode = p
    }
    address.isoCountryCode = "GBR"
    return address
     }
  
  func appendWithSpaceifNotEmpty(a: String, b: String?) -> String {
    var compString = a
    if let secondString = b {
      if compString != "" {
        compString.append(" \(secondString)")
      }else {
        compString = secondString
      }
      return compString
    }
    return ""
  }
  
  func addressAsString() -> String {
    
   // var a = CNPostalAddressFormatter.string(from: encodedAddress(), style: .mailingAddress )
     var a = ""
     a = appendWithSpaceifNotEmpty(a: a, b: street)
     a = appendWithSpaceifNotEmpty(a: a, b: city)
     a = appendWithSpaceifNotEmpty(a: a, b: postcode)
      return a
    }
}


