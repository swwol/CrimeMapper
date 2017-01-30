//
//  SearchResult.swift
//  StopAndSearch
//
//  Created by edit on 22/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Gloss
import CoreLocation
import MapKit
struct SearchResult: Decodable, Equatable {
  
  let type: String?
  let street: String?
  let gender: String?
  let latitude: String?
  let longitude: String?
  let age: String?
  let ethnicity: String?
  let dateTime: String?
  let mapAnnotation: MapAnnotation
  
  init?(json: JSON) {
    self.type = "type" <~~ json
    self.latitude = "location.latitude" <~~ json
    self.longitude  = "location.longitude" <~~ json
    self.street = "street" <~~ json
    self.ethnicity = "self_defined_ethnicity"  <~~ json
    self.gender = "gender" <~~ json
    self.age = "age_range" <~~ json
    self.dateTime = "datetime" <~~ json
    self.mapAnnotation = MapAnnotation(lat: latitude!, long: longitude!, title: type, subtitle: dateTime)
  }
}

func  == (lhs: SearchResult, rhs: SearchResult) -> Bool {
  
  if lhs.type == rhs.type &&
  lhs.street == rhs.street &&
  lhs.gender == rhs.gender &&
  lhs.latitude == rhs.latitude &&
  lhs.longitude == rhs.longitude &&
  lhs.age == rhs.age &&
  lhs.ethnicity == rhs.ethnicity &&
  lhs.dateTime == rhs.dateTime {
    return true
  } else {
    return false
  }
  
  
  
  
}
