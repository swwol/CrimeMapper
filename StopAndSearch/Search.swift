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
import PromiseKit


protocol SearchDelegate {
  func searchStarted()
  func searchCompleted(_ success: Bool)
  func searchStatus(cat: String, success: Bool)
}

typealias SearchComplete = ([SearchResult]) -> Void

class Search {
  var delegate: SearchDelegate?
  var sessionManager : SessionManager?
  var categoriesSearched: Int = 0
  let defaults = UserDefaults.standard
  let config : URLSessionConfiguration  = {
    let configuration = URLSessionConfiguration.default
    //  configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
    configuration.requestCachePolicy = .returnCacheDataElseLoad
    //configuration.urlCache = urlCache
    return configuration
  }()

  
  //////
  
  func cancelSearches() {
   // delegate?.searchCompleted(true)
    print ("cancelling all searches")
    sessionManager?.session.invalidateAndCancel()
  }
  
  func performSearch(coords: [CLLocationCoordinate2D],completion: @escaping SearchComplete) {
    delegate?.searchStarted()
    cancelSearches()
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
    
    /// this is the search loop
    
    var searches = [Promise<[SearchResult]>]()
    
    repeat {
      
      for selectedCat in selectedCats {
        
        let searchURL = getSearchURL(coords: coords, date: searchDate, cat: selectedCat)
        
        let s = doSearch( searchURL: searchURL)
        searches.append(s)
        
      }
      searchDate = searchDate.increment()
    } while ( searchDate <= endDate  )
    
    
    // out of loop 
    
    // set upo individual done actions for each search
    
    for (i,search) in searches.enumerated() {
      
      search.then {results -> Void in
      // completion(results)
        print (i)
        print (selectedCats[i%selectedCats.count])
        self.delegate?.searchStatus(cat: selectedCats[i%selectedCats.count].category, success: true)
        print ("search done for \(selectedCats[i%selectedCats.count].category)", results)
        }.catch { error in
          print ("search failed for \(selectedCats[i%selectedCats.count].category)", error)
           self.delegate?.searchStatus(cat: selectedCats[i%selectedCats.count].category, success: false)
      }
    }
    
   
    
    when (fulfilled: searches).then  {
      results -> Void in
      
    
      print ("all done")
     
       let flattenedResults  = results.flatMap { $0 }
      completion(flattenedResults)
       self.delegate?.searchCompleted(true)
      
      }.catch { _ in
         self.delegate?.searchCompleted(false)
        print ("errors for some cats")
        
    }
    
  }
  
  
  func doSearch( searchURL: URL) -> Promise<[SearchResult]> {
    
    return Promise { fulfill, reject in
      let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
      sessionManager!.request(searchURL)
      .validate()
        .responseJSON(queue: queue) { response in
          switch response.result {
          case .success(let dict):
            guard let jsonArray = dict as?  [NSDictionary] else {
             return
            }
            var searchResults  = [SearchResult]()
            for result in jsonArray {
              if let r = SearchResult(json: result as! JSON){
                searchResults.append(r)
              }
            }

            fulfill(searchResults)
          case .failure(let error):
            reject(error)
          }
      }
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
    /*
    searchString.append( "?poly=\(coords[0].latitude),\(coords[0].longitude):\(coords[1].latitude),\(coords[1].longitude):\(coords[2].latitude),\(coords[2].longitude):\(coords[3].latitude),\(coords[3].longitude)")
    */
    
    searchString.append("?poly=")
    
    for (i,coord) in coords.enumerated() {
      
      searchString.append ("\(coord.latitude),\(coord.longitude)")
      if i < coords.count - 1 {
        searchString.append(":")
      }
    }
    
    if let d = date {
      searchString.append("&date="+d.getDateFormattedForApiSearch())
    }


    let url = URL(string: searchString)
    return url!
  }
  
}
