//
//  Address.swift
//  StopAndSearch
//
//  Created by edit on 20/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Foundation
import Contacts

struct Address {
  

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
  
  func addressAsString() -> String {
    
    return CNPostalAddressFormatter.string(from: encodedAddress(), style: .mailingAddress )
    
  }
}




/*
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
 return s*/

