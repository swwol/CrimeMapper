//
//  SearchTableViewController.swift
//  StopAndSearch
//
//  Created by edit on 21/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit
import CoreLocation
import Gloss



class SearchTableViewController: UITableViewController {
  
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  var address: Address?
  var date: MonthYear?
  lazy var geocoder = CLGeocoder()
  var coordinate: CLLocationCoordinate2D?
  var searchResults = [SearchResult]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
      if segue.identifier == "SetAddress" {
        let controller = segue.destination as! AddressController
        controller.delegate = self        
      }
      
      if segue.identifier == "SetDate" {
        let controller = segue.destination as! DateController
        controller.delegate = self
      }
  }
  
  // did select go button
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.section == 2 && indexPath.row == 0 {
      
    //is there a valid location?
      
      guard let coord  = coordinate else {
       
        // alert need valid location
        return
      }
      // clear search results array of old results
      searchResults = []
      
      // get async queue
      
      let queue = DispatchQueue.global()
      queue.async {
        let url = self.getSearchURL( coordinate: coord, date: self.date)
        if let jsonString = self.performSearch(with: url) {
          let jsonArray =   self.parse(json: jsonString)
          if let array = jsonArray {
            for result in array {
              if  let r = SearchResult(json: result as! JSON){
                self.searchResults.append(r)
              }
            }
            print ("done")
            print (self.searchResults)
            return
          }
          print ("error")
        }
      }
    }
  }
  
  func parse(json: String) -> [NSDictionary]? {
    
    guard let data = json.data(using: .utf8, allowLossyConversion: false)
      else { return nil}
    do {
      return try JSONSerialization.jsonObject(with: data, options: []) as? [NSDictionary]
    } catch {
      print("JSON Error: \(error)")
      return nil
    }
  }
   
  func performSearch(with url: URL) -> String? {
    
    do {
      return try String(contentsOf: url, encoding: .utf8)
    } catch {
      print("Download Error: \(error)")
      return nil
    }
  }
    
    
  
  
  func getSearchURL (coordinate: CLLocationCoordinate2D, date: MonthYear? ) -> URL {
    
    // format search string
    
    var searchString = "https://data.police.uk/api/stops-street?lat=\(coordinate.latitude)&lng=\(coordinate.longitude)"
  
    if let d = date {
      print("adding date")
          searchString.append("&date="+d.dateFormattedForApiSearch)
    }
    print(searchString)
    let url = URL(string: searchString)
    return url!
  }
  
  
  
   func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
    
    if let error = error {
      print("Unable to Forward Geocode Address (\(error))")
      addressLabel.text! = "Unable to Find Location for Address"
      
    } else {
      var location: CLLocation?
      
      if let placemarks = placemarks, placemarks.count > 0 {
        location = placemarks.first?.location
      }
      
      if let location = location {
        coordinate = location.coordinate
        print( "\(coordinate!.latitude), \(coordinate!.longitude)")
      } else {
        print ( "No Matching Location Found")      }
    }
  }
  
  
}

extension SearchTableViewController: AddressControllerDelegate {
  
  func didSetAddress(address: Address) {
    coordinate = nil
    let addressString: String
    self.address = address
    addressString = self.address!.addressAsString()
    addressLabel.text!  = addressString
    geocoder.geocodeAddressString(addressString)  {
      (placemarks, error) in
      self.processResponse(withPlacemarks: placemarks, error: error)
    }
    //disable button and show activity monitor
  }
}

extension SearchTableViewController: DateControllerDelegate {
  
  func didSetDate(date: MonthYear) {
    self.date = date
    dateLabel.text!  = "\(date.monthName) \(date.yearAsString)"
    
    
  }
  
}
