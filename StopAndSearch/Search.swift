//
//  Search.swift
//  
//
//  Created by edit on 22/01/2017.
//
//

import Foundation
import CoreLocation
import Gloss


typealias SearchComplete = (Bool) -> Void

class Search {
  
  enum State {
    case notSearchedYet
    case loading
    case noResults
    case results([SearchResult])
  }
  
  private var dataTask: URLSessionDataTask? = nil
  private(set) var state: State = .notSearchedYet
  
  func performSearch(coord: CLLocationCoordinate2D, date: MonthYear?, completion: @escaping SearchComplete) {
   
    state = .loading
    
    // clear search results array of old results
   
    dataTask?.cancel()
    
    let url = getSearchURL( coordinate: coord, date: date)
    let session  = URLSession.shared
    dataTask  = session.dataTask(with: url, completionHandler: {
      data, response, error in
    
      self.state = .notSearchedYet
      var success = false
      
      if let error = error  as? NSError, error.code == -999 {
        return   // Search was cancelled
      }
    
      if let httpResponse = response as? HTTPURLResponse,httpResponse.statusCode == 200 {
        
        if let data = data, let jsonArray  = self.parse(json: data) {
          if jsonArray.isEmpty {
            self.state = .noResults
          } else {
            var searchResults  = [SearchResult]()
            for result in jsonArray {
              if let r = SearchResult(json: result as! JSON){
              searchResults.append(r)
              }
            }
            print (searchResults)
            self.state = .results(searchResults)
          }
        success = true
        }
      }
        DispatchQueue.main.async {
        completion(success)
      }
    })
    dataTask?.resume()
  }
  
   func parse(json data: Data) -> [NSDictionary]? {
    do {
      return try JSONSerialization.jsonObject(with: data, options: []) as? [NSDictionary]
    } catch {
      print("JSON Error: \(error)")
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
  
}
