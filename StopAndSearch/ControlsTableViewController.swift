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
  
var checked: [Bool]?
var crimeCategories = [[CrimeCategory]]()
  
 let topView = UIView()
 let topLabel = UILabel()
 let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
 let blurEffectView = UIVisualEffectView()
  
    override func viewDidLoad() {
      
      super.viewDidLoad()
      if checked == nil {
       checked = Array(repeating: true, count: Categories.categories.count)
        
      }
      
      navigationController?.delegate = self
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
   
      let cellNib = UINib(nibName: "CategoryCell", bundle: nil)
      tableView.register(cellNib, forCellReuseIdentifier: "CategoryCell")
      topView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
      setTopViewFrame()
      blurEffectView.effect = blurEffect
      blurEffectView.frame = topView.bounds
      topView.addSubview(blurEffectView)
      topLabel.frame = CGRect(x: 0, y: 5, width: self.view.frame.size.width, height: 50)
      topLabel.text = "Select crime categories to display"
      topLabel.textColor = UIColor.black
      topLabel.textAlignment = .center
      topLabel.font = topLabel.font.withSize(14)
      topView.addSubview(topLabel)
      navigationController?.view.addSubview(topView)
      tableView.contentInset = UIEdgeInsets(top: 60, left: 0 , bottom: 0 , right: 0)
      
      for type in Categories.types {
        let filteredByType = Categories.categories.filter{$0.type == type}
        if !filteredByType.isEmpty{
         crimeCategories.append(filteredByType)
        }
      }
    }
  
  func setTopViewFrame() {
    
    let nbh  = navigationController?.navigationBar.frame.size.height
    let nby  = navigationController?.navigationBar.frame.origin.y
    topView.frame = CGRect ( x: 0 , y: nbh! + nby!, width: self.view.frame.size.width, height: 60)
    topLabel.frame = CGRect(x: 0, y: 5, width: self.view.frame.size.width, height: 50)
    blurEffectView.frame = topView.bounds
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return Categories.types[section]
  }
  
  
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    
    setTopViewFrame()
    
  }
  
  
  func doneTapped() {
    print ("done")
    topView.removeFromSuperview()
  let _ = navigationController?.popViewController(animated: true)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return crimeCategories.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return crimeCategories[section].count
    }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
   
    if let cell = tableView.cellForRow(at: indexPath) {
      if cell.accessoryType == .checkmark {
        cell.accessoryType = .none
        checked![indexPath.row] = false
      } else {
        cell.accessoryType = .checkmark
        checked![indexPath.row] = true
      }
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell

        // Configure the cell...
      
      cell.categoryLabel.text = crimeCategories[indexPath.section][indexPath.row].category
      cell.categoryView.backgroundColor = crimeCategories[indexPath.section][indexPath.row].color
      cell.categoryView.layer.cornerRadius = cell.categoryView.frame.size.width/2
      cell.tintColor = UIColor.darkGray
      if !checked![indexPath.row] {
        cell.accessoryType = .none
      } else if checked![indexPath.row] {
        cell.accessoryType = .checkmark
      }
        return cell
    }
  
 
  
 override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     return 60
  }

  
  
}



extension ControlsTableViewController: UINavigationControllerDelegate {
  
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if let controller = viewController as? MapViewController {
      topView.removeFromSuperview()
     controller.selectedCategories  = checked
    }
  }
}
