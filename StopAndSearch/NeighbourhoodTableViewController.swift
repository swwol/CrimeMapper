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

class NeighbourhoodTableViewController: UITableViewController {
  
  typealias NeighbourhoodResult = ForceResult
  
  var force: String?
  var sessionManager : SessionManager?
  var loader: Loader?
  var neighbourhoodResults  = [NeighbourhoodResult]()
  let defaults = UserDefaults.standard

    override func viewDidLoad() {
    
      super.viewDidLoad()
      
      // add done button
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))

      tableView.contentInset = UIEdgeInsets(top: 60, left: 0 , bottom: 0 , right: 0)

        getNeighbourhoodData()
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
    
    // set accesory to none unless this cell id = saved id
    
    if let neighbourhoodId = defaults.object(forKey: "neighbourhood") {
      
      if let thisId = neighbourhoodResults[indexPath.row].id {
        
        if thisId == (neighbourhoodId as? String){
          
          cell.accessoryType = .checkmark
          
        } else {
            cell.accessoryType = .none
        }
        
      }
      
    } else {
      cell.accessoryType = .none

      
    }
    
    cell.textLabel?.text = neighbourhoodResults[indexPath.row].name
    cell.detailTextLabel?.text = "Id: \(neighbourhoodResults[indexPath.row].id!)"
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
    
    //deselect all rows
    
    for row in 0..<neighbourhoodResults.count {
      
      tableView.cellForRow(at: IndexPath(row: row, section: 0))?.accessoryType = .none
    }
    //select this one
     tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    // save force and neighbourhood id to userDefaults
    
    defaults.set(neighbourhoodResults[indexPath.row].id, forKey: "neighbourhood")
    defaults.set(force, forKey: "force")
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  
  func getNeighbourhoodData() {
    
    print ("getting data")
    
    //put loading box up
    
    if (loader == nil) {
      loader = Loader(message: "loading data...")
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


  }
