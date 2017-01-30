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
  
  let type: String?
  let street: String?
  let gender: String?
  var latitudeString: String? = nil
  var longitudeString: String? = nil
  let age: String?
  let ethnicity: String?
  let dateTime: String?
  
  var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  let title: String?
  let subtitle: String?
  var coordinate:CLLocationCoordinate2D{
    return CLLocationCoordinate2DMake(latitude, longitude)
  }

//  let mapAnnotation: MapAnnotation
  
  required init?(json: JSON) {
    self.type = "type" <~~ json
    self.latitudeString = "location.latitude" <~~ json
    self.longitudeString  = "location.longitude" <~~ json
    self.street = "street" <~~ json
    self.ethnicity = "self_defined_ethnicity"  <~~ json
    self.gender = "gender" <~~ json
    self.age = "age_range" <~~ json
    self.dateTime = "datetime" <~~ json
    
    self.latitude = Double(latitudeString!) ?? 0
    self.longitude = Double(longitudeString!) ?? 0
    self.title = self.type
    self.subtitle =  self.dateTime
    
    
  //  self.mapAnnotation = MapAnnotation(lat: latitude!, long: longitude!, title: type, subtitle: dateTime)
  }
}
/*
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
  
  */
  
  

