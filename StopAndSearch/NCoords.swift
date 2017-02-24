//
//  NCoords.swift
//  StopAndSearch
//
//  Created by edit on 24/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Foundation
import Gloss
import CoreLocation

class NCoords {
  
  let latString: String?
  let longString: String?
  var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  
    required init?(json: JSON) {
      self.latString  = "latitude" <~~ json
      self.longString  = "longitude" <~~ json
      self.latitude = Double(latString!) ?? 0
      self.longitude = Double(longString!) ?? 0
  }
}
