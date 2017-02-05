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
    self.month = "month" <~~ json
    self.latitude = Double(latitudeString!) ?? 0
    self.longitude = Double(longitudeString!) ?? 0

    self.subtitle = month
    
    
    if let c  = category {
      
      let a  = Categories.urls.index(of: c)
      self.title = Categories.categories[a!]
      self.color = Categories.colors[a!]
    } else {
      self.title = nil
      self.color = nil
    }
  //  self.subtitle =  self.dateTime
    
   //if let d = month {
      //trim date to 10 characters
      
    //  let index = d.index(d.startIndex, offsetBy: 10)
    //  let trimmedDate = d.substring(to: index)
    //  self.subtitle =
 //  } else {
    //  self.subtitle = nil
   // }

  }
}

  
 // if im a crime - i have category (title), coodinate, street, outcome, date

