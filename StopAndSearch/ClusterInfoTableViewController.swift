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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
      
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return cluster?.annotations.count ?? 0
  }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

      cell.textLabel?.text = cluster?.annotations[indexPath.row].title!
      cell.detailTextLabel?.text = cluster?.annotations[indexPath.row].subtitle!

        return cell
    }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    print ("selected cell at indexpath \(indexPath.row)" )
    
    //segue to detail view
    
    performSegue(withIdentifier: "showDetail", sender: cluster?.annotations[indexPath.row])
    
  }
  

  // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
      if segue.identifier  == "showDetail" {
        let controller = segue.destination as! DetailViewController
        controller.data = sender as? SearchResult
      }
  
  }
 
}
