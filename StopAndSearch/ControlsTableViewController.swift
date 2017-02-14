//
//  ControlsTableViewController.swift
//  StopAndSearch
//
//  Created by edit on 03/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//



import UIKit

class ControlsTableViewController: UITableViewController {
  
  var checked: [Bool]?
  var enabledSections: [Bool]?
  var TwoDChecked = [[Bool]]()
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
    
    if enabledSections == nil {
      enabledSections = Array(repeating: true, count: Categories.types.count)
    }
    
    navigationController?.delegate = self
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
    
    //register category cell
    let cellNib = UINib(nibName: "CategoryCell", bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: "CategoryCell")
    //register custom header cell
    
    let headerCellNib = UINib(nibName: "CustomHeaderCell", bundle: nil)
    tableView.register(headerCellNib, forCellReuseIdentifier: "HeaderCell")
    
    topView.backgroundColor = UIColor.flatMintDark.withAlphaComponent(0.33)
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
  
  func setTopViewFrame() {
    let nbh  = navigationController?.navigationBar.frame.size.height
    let nby  = navigationController?.navigationBar.frame.origin.y
    topView.frame = CGRect ( x: 0 , y: nbh! + nby!, width: self.view.frame.size.width, height: 60)
    topLabel.frame = CGRect(x: 0, y: 5, width: self.view.frame.size.width, height: 50)
    blurEffectView.frame = topView.bounds
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    setTopViewFrame()
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
        TwoDChecked[indexPath.section][indexPath.row] = false
      } else {
        cell.accessoryType = .checkmark
        TwoDChecked[indexPath.section][indexPath.row] = true
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
    print ("section \(section) value \(value)")
    
    self.enabledSections?[section] = value
    
    
    for i in 0..<crimeCategories[section].count {
      
      let indexpath = IndexPath(row: i, section: section)
      let cell =  self.tableView.cellForRow(at: indexpath) as! CategoryCell
      
      if value == false {
        
        disableCell(cell)
        
      } else {
        enableCell(cell)
      }
    }
  }
}

extension ControlsTableViewController: UINavigationControllerDelegate {
  
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if let controller = viewController as? MapViewController {
      topView.removeFromSuperview()
      checked = TwoDChecked.flatMap{$0}
      print (checked!)
      controller.selectedCategories  = checked
      controller.enabledSections = self.enabledSections
    }
  }
}
