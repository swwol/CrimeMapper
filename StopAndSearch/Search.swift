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
import Alamofire


protocol SearchDelegate {
  
  func searchStarted(for category: Int)
  
}

typealias SearchComplete = ((results:[SearchResult], cat: Int)) -> Void

class Search {
  
  enum State {
    case notSearchedYet
    case loading
    case noResults
    case results([SearchResult])
  }
  
  var delegate: SearchDelegate?
  private var dataTask: URLSessionDataTask? = nil
  private(set) var state: State = .notSearchedYet
  
  
  
  
  func performSearch(coords: [CLLocationCoordinate2D], date: MonthYear?, categories: [Bool]?, completion: @escaping SearchComplete) {
   
    
    
    if let cats = categories {
      
      for (index,cat) in cats.enumerated() {
        
        if cat == true {
          
          // perform a search on this category
          
          // get search url
          
          
          let searchURL = getSearchURL(coords: coords, date: date, catIndex: index)
         
          delegate?.searchStarted(for: index)
          
          Alamofire.request(searchURL).responseJSON { response in
           
            if let status = response.response?.statusCode {
              switch(status){
              case 200:
                print("example success")
              case 503:
                print ("too many results")
              default:
                print("error with response status: \(status)")
              }
            }
            if let result = response.result.value {
              let jsonArray = result as! [NSDictionary]
              var searchResults  = [SearchResult]()
              
              for result in jsonArray {
                if let r = SearchResult(json: result as! JSON){
                  searchResults.append(r)
                }
              }
             
              DispatchQueue.main.async {
                completion((results:searchResults, cat: index))
              }
            }
          }
        }
      }
    }
  }
  

  func getSearchURL (coords: [CLLocationCoordinate2D], date: MonthYear?, catIndex: Int? ) -> URL {
    
    // format search string
    var searchString: String
    if let cat = catIndex {
      
      let catString = Categories.urls[cat]
      searchString = "https://data.police.uk/api/crimes-street/"+catString
    }
    
    else {
      searchString = "https://data.police.uk/api/crimes-street/all-crime"
    }
    
    searchString.append( "?poly=\(coords[0].latitude),\(coords[0].longitude):\(coords[1].latitude),\(coords[1].longitude):\(coords[2].latitude),\(coords[2].longitude):\(coords[3].latitude),\(coords[3].longitude)")
    
    if let d = date {
      searchString.append("&date="+d.dateFormattedForApiSearch)
    }

    let url = URL(string: searchString)
    return url!
  }
  
}
