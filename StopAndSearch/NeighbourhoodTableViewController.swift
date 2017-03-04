//
//  NeighbourhoodTableViewController.swift
//  StopAndSearch
//
//  Created by edit on 24/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit
import Alamofire
import Gloss
import Foundation

class NeighbourhoodTableViewController: UITableViewController {
  
  typealias NeighbourhoodResult = ForceResult
  
  var force: String?
  var sessionManager : SessionManager?
  var loader: Loader?
  var neighbourhoodResults  = [NeighbourhoodResult]()
  var filteredResults = [NeighbourhoodResult]()
  let defaults = UserDefaults.standard
  var searchController:UISearchController!

    override func viewDidLoad() {
    
      super.viewDidLoad()
      
      searchController = UISearchController(searchResultsController: nil)
      searchController.hidesNavigationBarDuringPresentation = false
      // this is to make cursor not white!
      let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
      textFieldInsideSearchBar?.tintColor = UIColor.lightGray
      let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
      textFieldInsideSearchBarLabel?.text = "search for police force..."
      searchController.searchResultsUpdater = self
      searchController.dimsBackgroundDuringPresentation = false

      // add done button
     let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
      //add search button to nav bar
     let searchButton = UIBarButtonItem( barButtonSystemItem: .search, target: self, action: #selector(showSearch))
      navigationItem.rightBarButtonItems = [doneButton, searchButton]
      tableView.contentInset = UIEdgeInsets(top: 60, left: 0 , bottom: 0 , right: 0)

        getNeighbourhoodData()
    }
  
  func showSearch() {
    
    present(searchController, animated: true, completion: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tableView.reloadData()
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func doneTapped(){
    //pop back to root
    let _ = navigationController?.popToRootViewController(animated: true)
  }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
      
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if searchController.isActive && searchController.searchBar.text != "" {
        return filteredResults.count
      }
        return neighbourhoodResults.count
    }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return 60
    
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell: UITableViewCell = {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") else {
        // Never fails:
        return UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "UITableViewCell")
      }
      return cell
    }()
    // set highlight
    let myCustomSelectionColorView = UIView()
    myCustomSelectionColorView.backgroundColor = UIColor.flatMint.withAlphaComponent(0.3)
    cell.selectedBackgroundView = myCustomSelectionColorView
    
    
    var arrayToUse : [NeighbourhoodResult]
      if searchController.isActive && searchController.searchBar.text != "" {
        arrayToUse = filteredResults
      } else {
       arrayToUse = neighbourhoodResults
    }
    
    // set accesory to none unless this cell id = saved id
    
    if let neighbourhoodId = defaults.object(forKey: "neighbourhood") {
      if let thisId = arrayToUse[indexPath.row].id {
        if thisId == (neighbourhoodId as? String){
          cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
      }
    } else {
      cell.accessoryType = .none
    }
    cell.textLabel?.text = arrayToUse[indexPath.row].name
    cell.detailTextLabel?.text = "Id: \(arrayToUse[indexPath.row].id!)"
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
    
    
    
    //deselect all rows
    
    for row in 0..<tableView.numberOfRows(inSection: 0) {
      
      tableView.cellForRow(at: IndexPath(row: row, section: 0))?.accessoryType = .none
    }
    //select this one
     tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    // save force and neighbourhood id to userDefaults
    
      if searchController.isActive && searchController.searchBar.text != "" {
        defaults.set(filteredResults[indexPath.row].id, forKey: "neighbourhood")
        defaults.set(true, forKey: "searchUpdated")
      } else {
         defaults.set(neighbourhoodResults[indexPath.row].id, forKey: "neighbourhood")
        defaults.set(true, forKey: "searchUpdated")
    }
    defaults.set(force, forKey: "force")
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  
  func getNeighbourhoodData() {
    
    print ("getting data")
    
    //put loading box up
    
    if (loader == nil) {
      loader = Loader(message: "loading data...", size: "small")
      loader?.alpha = 0
      loader?.center = view.center
      self.view.addSubview(loader!)
    }
    UIView.animate(withDuration: 0.5, animations: {self.loader?.alpha = 1})
    
    
    let config : URLSessionConfiguration  = {
      let configuration = URLSessionConfiguration.default
      //  configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
      configuration.requestCachePolicy = .returnCacheDataElseLoad
      //configuration.urlCache = urlCache
      return configuration
    }()
    
    sessionManager = Alamofire.SessionManager(configuration: config)
    
    let searchURL  = URL(string: "https://data.police.uk/api/\(force!)/neighbourhoods")
    
    sessionManager?.request(searchURL!).responseJSON { response in
      
      if let status = response.response?.statusCode {
        
        switch(status){
        case 200:
          print("getting neighbourhood data example success")
        default:
          print("error getting forces data")
        }
      }
      if let result = response.result.value {
        let jsonArray = result as! [NSDictionary]
        self.neighbourhoodResults  = []
        for result in jsonArray {
          if let r = NeighbourhoodResult(json: result as! JSON){
            self.neighbourhoodResults.append(r)
          }
          self.neighbourhoodResults = self.neighbourhoodResults.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending}

        }
        DispatchQueue.main.async {
          // kill loader
          self.loader?.activityIndicator.stopAnimating()
          self.loader?.removeFromSuperview()
          self.loader = nil
          //reload table
          self.tableView.reloadData()
        }
      }
    }
  }
  
  func filterContentForSearchText(searchText: String, scope: String = "All") {
    print (searchText)
    filteredResults = neighbourhoodResults.filter {
      ($0.name?.lowercased().contains(searchText.lowercased()))!
    }
    tableView.reloadData()
  }
  }

extension NeighbourhoodTableViewController: UISearchResultsUpdating  {
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchText: searchController.searchBar.text!)
  }
}
