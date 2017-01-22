//
//  Location.swift
//  StopAndSearch
//
//  Created by edit on 22/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Foundation
import Gloss
import CoreLocation

struct Location : Decodable {
  
  let latitude: CLLocationDegrees?
  let longitude: CLLocationDegrees?
  
  init?(json: JSON) {
    self.latitude = "latitude" <~~ json
    self.longitude = "longitude" <~~ json
  }
}
