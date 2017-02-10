//
//  ClusterInfoTableViewController.swift
//  StopAndSearch
//
//  Created by edit on 03/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class ClusterInfoTableViewController: UITableViewController {
  
  var cluster: FBAnnotationCluster?
  var clusterContents = [[SearchResult]]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let c = cluster {
      let searchResults  = c.annotations as! [SearchResult]
      for category in Categories.categories {
        let filterdArray = searchResults.filter{$0.title! == category.category}
        if !filterdArray.isEmpty {
          clusterContents.append(filterdArray)
        }
      }
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return clusterContents.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return clusterContents[section].count
  }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

      let resultToDisplay  = clusterContents[indexPath.section][indexPath.row]

      cell.textLabel?.text = resultToDisplay.title!
      cell.detailTextLabel?.text = resultToDisplay.subtitle!
      cell.backgroundColor = resultToDisplay.color!
      return cell
    }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    print ("selected cell at indexpath \(indexPath.row)" )
    
    //segue to detail view
    
    performSegue(withIdentifier: "showDetail", sender: cluster?.annotations[indexPath.row])
    
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "title"
  }
  

  // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
      if segue.identifier  == "showDetail" {
        let controller = segue.destination as! DetailViewController
        controller.data = sender as? SearchResult
      }
  
  }
 
}
