//
//  SearchResult.swift
//  StopAndSearch
//
//  Created by edit on 22/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//
import Foundation
import Gloss
import CoreLocation
import MapKit
class SearchResult: NSObject,Decodable,MKAnnotation {

  let category: String?
  let street: String?
  var latitudeString: String? = nil
  var longitudeString: String? = nil
  let month: String?
  
  var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  let title: String?
  let subtitle: String?
  let outcome: String?
  let outcome_date: String?
  let color: UIColor?
  var coordinate:CLLocationCoordinate2D{
    return CLLocationCoordinate2DMake(latitude, longitude)
  }

//  let mapAnnotation: MapAnnotation
  
  required init?(json: JSON) {
    self.category = "category" <~~ json
    self.latitudeString = "location.latitude" <~~ json
    self.longitudeString  = "location.longitude" <~~ json
    self.street = "location.street.name" <~~ json
    self.outcome = "outcome_status.category"  <~~ json
    self.outcome_date = "outcome_status.date"  <~~ json
    self.month = "month" <~~ json
    self.latitude = Double(latitudeString!) ?? 0
    self.longitude = Double(longitudeString!) ?? 0
    self.subtitle = month
  
    if let c  = category {
      let a = Categories.categories.filter { $0.url == c }
      self.title = a[0].category
      self.color =  a[0].color
    } else {
      print ("INVALID CATEGORY!!!!!!!")
      self.title = nil
      self.color = nil
    }
  }
}
  
 // if im a crime - i have category (title), coodinate, street, outcome, date

