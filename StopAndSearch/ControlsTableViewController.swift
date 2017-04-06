//
//  ControlsTableViewController.swift
//  StopAndSearch
//
//  Created by edit on 03/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//



import UIKit
import Foundation

class ControlsTableViewController: UITableViewController,InitialisesExtendedNavBar {
  
  //propertieas to initialise xnavbar with if vc is navigated to
  
  var extendedNavBarColor = UIColor.flatMintDark.withAlphaComponent(0.33)
  var extendedNavBarMessage =  "select crime categories to display"
  var extendedNavBarShouldShowDate = false
  var extendedNavBarFontSize: CGFloat  = 14
  var extendedNavBarFontColor = UIColor.flatBlackDark
  var extendedNavBarIsHidden: Bool = false
  //
  var checked: [Bool]?
  var enabledSections: [Bool]?
  var TwoDChecked = [[Bool]]()
  var crimeCategories = [[CrimeCategory]]()
  let defaults = UserDefaults.standard
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    // add done button
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
    
    //register category cell
    let cellNib = UINib(nibName: "CategoryCell", bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: "CategoryCell")
    
    //register custom header cell
    let headerCellNib = UINib(nibName: "CustomHeaderCell", bundle: nil)
    tableView.register(headerCellNib, forCellReuseIdentifier: "HeaderCell")
    tableView.contentInset = UIEdgeInsets(top: 60, left: 0 , bottom: 0 , right: 0)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
  
    // read in checked and enabled arrays from disk
    checked = defaults.array(forKey: "selectedCategories") as? [Bool] ?? Array(repeating: true, count: Categories.categories.count)
    enabledSections = defaults.array(forKey: "enabledSections") as? [Bool] ?? Array(repeating: true, count: Categories.types.count)

    //break categories and checked into 2d array
    var n = 0
    for type in Categories.types {
      let filteredByType = Categories.categories.filter{$0.type == type}
      if !filteredByType.isEmpty{
        crimeCategories.append(filteredByType)
        let subChecked = checked![n..<(n + filteredByType.count)]
        TwoDChecked.append(Array(subChecked))
        n += (filteredByType.count)
      }
    }
    print (TwoDChecked)
    
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! CustomHeaderCell
    cell.categoryTitle.text = Categories.types[section]
    cell.bg.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    cell.categorySwitch.tintColor = .flatMint
    cell.categorySwitch.isOn = (enabledSections?[section])!
    cell.categorySwitch.onTintColor = .flatGreen
    cell.mySection = section
    cell.delegate = self
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 44
  }
  
  
  func doneTapped() {
    print ("done")
    let _ = navigationController?.popToRootViewController(animated: true)
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
        TwoDChecked[indexPath.section][indexPath.row] = false
        checked = TwoDChecked.flatMap{$0}
        //save array to user defaults
        defaults.set(checked,forKey:"selectedCategories" )
        defaults.set(true, forKey: "searchUpdated")

      } else {
        cell.accessoryType = .checkmark
        TwoDChecked[indexPath.section][indexPath.row] = true
        checked = TwoDChecked.flatMap{$0}
        //save array to user defaults
        defaults.set(checked,forKey:"selectedCategories" )
        defaults.set(true, forKey: "searchUpdated")

      }
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
    if cell.typeLabel != nil {
      cell.typeLabel.removeFromSuperview()
    }
    cell.categoryLabel.text = crimeCategories[indexPath.section][indexPath.row].category
    cell.categoryView.backgroundColor = crimeCategories[indexPath.section][indexPath.row].color
    cell.categoryView.layer.cornerRadius = cell.categoryView.frame.size.width/2
    cell.tintColor = UIColor.darkGray
    if !TwoDChecked[indexPath.section][indexPath.row]{
      cell.accessoryType = .none
    } else if TwoDChecked[indexPath.section][indexPath.row] {
      cell.accessoryType = .checkmark
    }
    if (enabledSections?[indexPath.section])! {
      enableCell(cell)
    } else {
      disableCell(cell)
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
}

func disableCell (_ cell: CategoryCell) {
  cell.categoryLabel.isEnabled = false
  cell.categoryView.backgroundColor = cell.categoryView.backgroundColor?.withAlphaComponent(0.4)
  cell.tintColor = cell.tintColor.withAlphaComponent(0.4)
  cell.isUserInteractionEnabled = false
  if cell.overlay == nil {
    cell.overlay = UIView()
    cell.overlay?.frame = cell.bounds
    cell.overlay?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    cell.contentView.addSubview(cell.overlay!)
  }
  cell.contentView.bringSubview(toFront: cell.overlay!)
}

func enableCell (_ cell: CategoryCell) {
  cell.categoryLabel.isEnabled = true
  cell.categoryView.backgroundColor = cell.categoryView.backgroundColor?.withAlphaComponent(1)
  cell.tintColor = cell.tintColor.withAlphaComponent(1)
  cell.isUserInteractionEnabled = true
  cell.overlay?.removeFromSuperview()
  cell.overlay = nil
}

extension ControlsTableViewController: CustomHeaderCellDelegate {
  
  func switched(section: Int, value: Bool) {
    self.enabledSections?[section] = value
    for i in 0..<crimeCategories[section].count {
      let indexpath = IndexPath(row: i, section: section)
     print ("row",i)
      // something crashed here!
      print ("sssection",section)
     print ("indexpath",indexpath)
      if let cell =  self.tableView.cellForRow(at: indexpath) as? CategoryCell {
      if value == false {
        disableCell(cell)
      } else {
        enableCell(cell)
      }
      } else {print ("would have crashed")}
    }
  
    //save array to user defaults
    defaults.set(enabledSections,forKey:"enabledSections" )
    defaults.set(true, forKey: "searchUpdated")

  }
}
