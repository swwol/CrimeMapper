//
//  MapAnnotation.swift
//  StopAndSearch
//
//  Created by edit on 23/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
  
  var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  var title: String?
  var subtitle: String?
  var coordinate:CLLocationCoordinate2D{
     return CLLocationCoordinate2DMake(latitude, longitude)
  }

  init(lat: String, long: String, title: String? = nil, subtitle: String? = nil) {
    
    self.latitude = Double(lat) ?? 0
    self.longitude = Double(long) ?? 0
    self.title = title
    self.subtitle = subtitle
  }
}
