//
//  RegionsTableViewController.swift
//  StopAndSearch
//
//  Created by edit on 23/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit
import Alamofire
import Gloss
import Foundation

class RegionsTableViewController: UITableViewController,InitialisesExtendedNavBar  {
  
  //propertieas to initialise xnavbar with if vc is navigated to
  
  var extendedNavBarColor = UIColor.flatMintDark.withAlphaComponent(0.33)
  var extendedNavBarMessage =  "select region to display"
  var extendedNavBarShouldShowDate = false
  var extendedNavBarFontSize: CGFloat  = 14
  var extendedNavBarFontColor = UIColor.flatBlackDark
  var extendedNavBarIsHidden: Bool = false
  //

 var searchController:UISearchController!
   var sessionManager : SessionManager?
   var loader: Loader?
   var forceResults  = [ForceResult]()
   let defaults = UserDefaults.standard
   var filteredResults = [ForceResult]()
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
    // definesPresentationContext = true

    //add search button to nav bar
    navigationItem.rightBarButtonItem = UIBarButtonItem( barButtonSystemItem: .search, target: self, action: #selector(showSearch))
    
    tableView.contentInset = UIEdgeInsets(top: 60, left: 0 , bottom: 0 , right: 0)
    let headerCellNib = UINib(nibName: "CustomHeaderCell", bundle: nil)
    tableView.register(headerCellNib, forCellReuseIdentifier: "HeaderCell")
    getForcesData()
    }
  
  func showSearch() {
    
    present(searchController, animated: true, completion: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 34
  }

  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! CustomHeaderCell
    cell.categoryTitle.text = ""
    cell.bg.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    if cell.categorySwitch != nil {
      cell.categorySwitch.removeFromSuperview()
    }
    return cell
  }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if section == 0 {
        return 1
      } else {
         if searchController.isActive && searchController.searchBar.text != "" {
          return filteredResults.count
        }
          return forceResults.count
      }
    }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return 60
    
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
    // set cell prototype
    
    let cell: UITableViewCell = {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") else {
        // Never fails:
        return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "UITableViewCell")
      }
      return cell
    }()
    // set highlight
    let myCustomSelectionColorView = UIView()
    myCustomSelectionColorView.backgroundColor = UIColor.flatMint.withAlphaComponent(0.3)
    cell.selectedBackgroundView = myCustomSelectionColorView
    //
    // set attributes
    if indexPath.section == 1 {
    cell.accessoryType = .disclosureIndicator
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.textLabel?.text = filteredResults[indexPath.row].name
        } else {
    cell.textLabel?.text = forceResults[indexPath.row].name
      }
      return cell
    }
    else {
      cell.textLabel?.text = "visible map region"
      
      if let n  = defaults.object(forKey: "neighbourhood") {
        
        if let _  = n as? String {
       cell.accessoryType = .none
        } else {
          cell.accessoryType = .checkmark
        }
      }
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.section == 0 {
      defaults.set(nil, forKey: "neighbourhood")
      defaults.set(true, forKey: "searchUpdated")
      tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
      tableView.deselectRow(at: indexPath, animated: true)
    } else {
      
      if searchController.isActive && searchController.searchBar.text != "" {
        performSegue(withIdentifier: "neighbourhoods", sender: filteredResults[indexPath.row].id)
      } else {
        
        performSegue(withIdentifier: "neighbourhoods", sender: forceResults[indexPath.row].id)
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "neighbourhoods" {
      
      if let controller = segue.destination as? NeighbourhoodTableViewController{
        
        controller.force  = sender as! String?
        
      }
    }
  }
  
  func getForcesData() {
    
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

     let searchURL  = URL(string: "https://data.police.uk/api/forces")
    
    sessionManager?.request(searchURL!).responseJSON { response in
      
      if let status = response.response?.statusCode {
        
        switch(status){
        case 200:
          print("getting forces data success")
        default:
          print("error getting forces data")
          }
      }
      if let result = response.result.value {
        let jsonArray = result as! [NSDictionary]
        self.forceResults  = []
        for result in jsonArray {
          if let r = ForceResult(json: result as! JSON){
            self.forceResults.append(r)
          }
          //sort alphabetically
          self.forceResults = self.forceResults.sorted { $0.name?.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending}
          
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
    filteredResults = forceResults.filter {
      ($0.name?.lowercased().contains(searchText.lowercased()))!
    }
    
    tableView.reloadData()
  }
  
}

extension RegionsTableViewController: UISearchResultsUpdating  {
  func updateSearchResults(for searchController: UISearchController) {
      filterContentForSearchText(searchText: searchController.searchBar.text!)
  }
}
