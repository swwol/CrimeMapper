//
//  ControlsTableViewController.swift
//  StopAndSearch
//
//  Created by edit on 03/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//


//Anti-social behavior
//bicycle theft
//burgalry
//criminal damagge and arson
//drugs
//other theft
//possesion of weapons
//public order
//robbery
//shoplifing
//theft from the person
//vehicle crime
//violent and sexual
//other
// stop and search


import UIKit

class ControlsTableViewController: UITableViewController {
  
var checked: [Bool] = Array(repeating: true, count: Categories.categories.count)
  
    override func viewDidLoad() {
        super.viewDidLoad()
      navigationController?.delegate = self

   
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
        return 14
    }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    
    if let cell = tableView.cellForRow(at: indexPath) {
      if cell.accessoryType == .checkmark {
        cell.accessoryType = .none
        checked[indexPath.row] = false
      } else {
        cell.accessoryType = .checkmark
        checked[indexPath.row] = true
      }
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "controlCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = Categories.categories[indexPath.row]
        cell.tintColor = UIColor.darkGray
      if !checked[indexPath.row] {
        cell.accessoryType = .none
      } else if checked[indexPath.row] {
        cell.accessoryType = .checkmark
      }
        return cell
    }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Choose categories of crime to display"
  }
}

extension ControlsTableViewController: UINavigationControllerDelegate {
  
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if let controller = viewController as? MapViewController {
     controller.selectedCategories  = checked
    }
  }
}
