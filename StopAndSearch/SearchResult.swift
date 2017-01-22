//
//  SearchResult.swift
//  StopAndSearch
//
//  Created by edit on 22/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Gloss
import CoreLocation

struct SearchResult: Decodable {
  
  let type: String?
  let street: String?
  let gender: String?
  let latitude: String?
  let longitude: String?
  let age: String?
  let ethnicity: String?
  let objectOfSearch: String?
  
  init?(json: JSON) {
    self.type = "type" <~~ json
    self.latitude = "location.latitude" <~~ json
    self.longitude  = "location.longitude" <~~ json
    self.street = "street" <~~ json
    self.ethnicity = "self_defined_ethnicity"  <~~ json
    self.gender = "gender" <~~ json
    self.age = "age_range" <~~ json
    self.objectOfSearch = "object_of_seearch" <~~ json
  }
}
