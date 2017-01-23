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
  
  func addStringOrSpacedString (firstString: String, secondString: String) -> String {
    var s: String
    if   firstString != "" {
      s = firstString + " " + secondString
    } else {
      s = secondString
    }
    return s
  }
  
  func addressFormattedForLabel()-> String {
    var add = ""
    if let s = street {
    add = addStringOrSpacedString(firstString: add, secondString: s)
    }
    if let c = city {
      add = addStringOrSpacedString(firstString: add, secondString: c)
    }
    if let p = postcode {
      add = addStringOrSpacedString(firstString: add, secondString: p)
    }
    return add    
  }
  
  func addressAsString() -> String {
   return CNPostalAddressFormatter.string(from: encodedAddress(), style: .mailingAddress )
    }
}


