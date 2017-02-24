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

class RegionsTableViewController: UITableViewController {

   var sessionManager : SessionManager?
   var loader: Loader?
   var forceResults  = [ForceResult]()

  override func viewDidLoad() {
    
        super.viewDidLoad()
    tableView.contentInset = UIEdgeInsets(top: 60, left: 0 , bottom: 0 , right: 0)

        getForcesData()
   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return forceResults.count
    }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return 60
    
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
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
    cell.accessoryType = .disclosureIndicator
    cell.textLabel?.text = forceResults[indexPath.row].name
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "neighbourhoods", sender: forceResults[indexPath.row].id)
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

     let searchURL  = URL(string: "https://data.police.uk/api/forces")
    
    sessionManager?.request(searchURL!).responseJSON { response in
      
      if let status = response.response?.statusCode {
        
        switch(status){
        case 200:
          print("example success")
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



