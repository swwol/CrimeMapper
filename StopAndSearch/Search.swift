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
  
  func searchStarted()
  func searchComplete(tooMany: Int, unknown: Int)
  
}

typealias SearchComplete = ((results:[SearchResult], cat: CrimeCategory)) -> Void

class Search {
  
  
  var delegate: SearchDelegate?
  var sessionManager : SessionManager?
  var categoriesSearched: Int = 0
  var unknownErrors: Int = 0
  var tooManyResultsErrors: Int = 0
  let defaults = UserDefaults.standard
  
  func cancelSearches() {
    
    print ("cancelling all searches")
    sessionManager?.session.invalidateAndCancel()
  }
  
  func performSearch(coords: [CLLocationCoordinate2D],completion: @escaping SearchComplete) {
    
    cancelSearches()
    delegate?.searchStarted()
    let config : URLSessionConfiguration  = {
      let configuration = URLSessionConfiguration.default
      //  configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
      configuration.requestCachePolicy = .returnCacheDataElseLoad
      //configuration.urlCache = urlCache
      return configuration
    }()
    
    sessionManager = Alamofire.SessionManager(configuration: config)
    
    //read in selected categories and sections from disk or set all to true if null
    
    let cats = defaults.array(forKey: "selectedCategories") as? [Bool] ?? Array(repeating: true, count: Categories.categories.count)
    let sects  = defaults.array(forKey: "enabledSections") as? [Bool] ?? Array(repeating: true, count: Categories.types.count)
    
    // first get selected cats
    var selectedCats = [CrimeCategory]()
    for (i,cat) in cats.enumerated() {
      if cat {
        selectedCats.append(Categories.categories[i])
      }
    }
    // now filter out the ones that are in disabled sections
    for (i,sect) in sects.enumerated() {
      if !sect {
        selectedCats = selectedCats.filter{ $0.type !=  Categories.types[i]   }
      }
    }
    
    let startMonth = defaults.integer(forKey: "startMonth")
    let startYear = defaults.integer(forKey: "startYear")
    let endMonth = defaults.integer(forKey: "endMonth")
    let endYear = defaults.integer(forKey: "endYear")
    let monthLastUpdated = defaults.integer(forKey: "monthLastUpdated")
    let yearLastupdated  = defaults.integer(forKey: "yearLastUpdated")
    var startDate: MonthYear
    if startMonth != 0 {
      startDate = MonthYear(month: startMonth, year: startYear)
    }
    else {
      startDate = MonthYear(month: monthLastUpdated, year: yearLastupdated)
    }
    var endDate: MonthYear
    if endMonth != 0 {
      endDate = MonthYear(month: endMonth, year: endYear)
    }
    else {
      endDate = startDate
    }
    
    var searchDate: MonthYear  = startDate
    
    repeat {
      
      for selectedCat in selectedCats {
        categoriesSearched =  0
        unknownErrors = 0
        tooManyResultsErrors = 0
        
        let searchURL = getSearchURL(coords: coords, date: searchDate, cat: selectedCat)
        
        sessionManager?.request(searchURL).responseJSON { response in
          
          if let status = response.response?.statusCode {
            
            switch(status){
            case 200:
              print("example success")
            case 503:
              print ("too many results")
              self.incrementSearchCount(error: status, numCats: selectedCats.count)
            default:
              print("error with response status: \(status)")
              self.incrementSearchCount(error: status, numCats: selectedCats.count)
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
              completion((results:searchResults, cat: selectedCat))
              self.incrementSearchCount(error: 0, numCats: selectedCats.count)
            }
            
          }
        }
        
      }
      searchDate = searchDate.increment()
    } while ( searchDate <= endDate  )
    
  }
  
  func incrementSearchCount( error: Int, numCats: Int ) {
    
    categoriesSearched += 1
    
    if (error == 503) {
      
      tooManyResultsErrors += 1
    } else if (error != 0 ) {
      
      unknownErrors += 1
    }
    if categoriesSearched == numCats {
      print ("all searches completed")
      self.delegate?.searchComplete(tooMany: tooManyResultsErrors, unknown: unknownErrors)
    }
  }
  func getSearchURL (coords: [CLLocationCoordinate2D], date: MonthYear?, cat: CrimeCategory? ) -> URL {
    // format search string
    var searchString: String
    if let c = cat {
      let catString = c.url
      searchString = "https://data.police.uk/api/crimes-street/"+catString
    }
    else {
      searchString = "https://data.police.uk/api/crimes-street/all-crime"
    }
    
    searchString.append( "?poly=\(coords[0].latitude),\(coords[0].longitude):\(coords[1].latitude),\(coords[1].longitude):\(coords[2].latitude),\(coords[2].longitude):\(coords[3].latitude),\(coords[3].longitude)")
    
    if let d = date {
      searchString.append("&date="+d.getDateFormattedForApiSearch())
    }

    let url = URL(string: searchString)
    return url!
  }
  
}
