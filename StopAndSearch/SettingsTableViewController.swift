//
//  SettingsTableViewController.swift
//  StopAndSearch
//
//  Created by edit on 21/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableViewController: UITableViewController,InitialisesExtendedNavBar {

  
  //propertieas to initialise xnavbar with if vc is navigated to
  var extendedNavBarColor = UIColor.flatMintDark.withAlphaComponent(0.33)
  var extendedNavBarMessage =  "configure search settings"
  var extendedNavBarShouldShowDate = false
  var extendedNavBarFontSize: CGFloat  = 14
  var extendedNavBarFontColor = UIColor.flatBlackDark
  var extendedNavBarIsHidden = false
  
  //

  var startMonth: Int = 0
  var startYear: Int = 0
  var endMonth: Int = 0
  var endYear: Int = 0
  var monthLastUpdated: Int = 0
  var yearLastUpdated: Int = 0
  var neighbourhoodID: String?
  let defaults = UserDefaults.standard
  
    override func viewDidLoad() {
        super.viewDidLoad()

      tableView.contentInset = UIEdgeInsets(top: 60, left: 0 , bottom: 0 , right: 0)
      let headerCellNib = UINib(nibName: "CustomHeaderCell", bundle: nil)
      tableView.register(headerCellNib, forCellReuseIdentifier: "HeaderCell")
      
      }
  
  override func viewWillAppear(_ animated: Bool) {
    
    //try reading startDate and endDate
    
    startMonth  = defaults.integer(forKey: "startMonth")
    startYear  = defaults.integer(forKey: "startYear")
    endMonth  = defaults.integer(forKey: "endMonth")
    endYear  = defaults.integer(forKey: "endYear")
    monthLastUpdated = defaults.integer(forKey: "monthLastUpdated")
    yearLastUpdated = defaults.integer(forKey: "yearLastUpdated")
    if let nId  = defaults.object(forKey: "neighbourhood") {
      neighbourhoodID = nId as? String
    } else {
      neighbourhoodID = nil
    }
    
    
    
    tableView.reloadData()
  }
  

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if section == 1 {
        return 2
      } else {
        return 1
      }
    }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 34
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

    let myCustomSelectionColorView = UIView()
    myCustomSelectionColorView.backgroundColor = UIColor.flatMint.withAlphaComponent(0.3)
    cell.selectedBackgroundView = myCustomSelectionColorView

    if indexPath.section == 0 {
      // for set crimes section
      cell.textLabel?.text = "edit categories"
      cell.detailTextLabel?.text = ""
      cell.imageView?.image = UIImage(named: "cats")
      
    }
    
    if indexPath.section == 1 && indexPath.row == 0 {
      // start date
      cell.textLabel?.text = "start date"
      if startMonth == 0 {
        // if no startDate set, use latest data available
        cell.detailTextLabel?.text = MonthYear(month: monthLastUpdated,year: yearLastUpdated).getDateAsString()
      } else {
      cell.detailTextLabel?.text = MonthYear(month: startMonth, year: startYear).getDateAsString()
      }
      cell.imageView?.image = UIImage(named: "date")
    }
    
    if indexPath.section == 1 && indexPath.row == 1 {
      // end date
      cell.textLabel?.text = "end date"
      if endMonth == 0 {
        // if no endDate
        cell.detailTextLabel?.text = "not set"
      } else {
        cell.detailTextLabel?.text = MonthYear(month: endMonth , year: endYear).getDateAsString()
      }

      cell.imageView?.image = UIImage(named: "date")
    }
    
    if indexPath.section == 2 {
      // region
      cell.textLabel?.text = "set region"
      
      if let n = neighbourhoodID {
      cell.detailTextLabel?.text = n
      } else {
        cell.detailTextLabel?.text = "visible"
      }
      cell.imageView?.image = UIImage(named: "region")
    }
    
    if indexPath.section == 3 {
      // about
      cell.textLabel?.text = "info about this app"
   
      cell.imageView?.image = UIImage(named: "navHead")
    }
 
  //  cell.textLabel?.text = "text"
   // cell.detailTextLabel?.text = "detail"
    cell.accessoryType = .disclosureIndicator
    return cell
    
  }
  
 override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! CustomHeaderCell
  switch section {
   
  case 0:
    cell.categoryTitle.text = "set crime categories"
  case 1:
    cell.categoryTitle.text = "set date range"
  case 2:
    cell.categoryTitle.text = "set map region"
  case 3:
    cell.categoryTitle.text = "about this app"
  default:
     cell.categoryTitle.text = ""
  }
    cell.bg.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    if cell.categorySwitch != nil {
      cell.categorySwitch.removeFromSuperview()
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.section == 0 {
    performSegue(withIdentifier: "categories", sender: nil)
    }
    if indexPath.section == 1 && indexPath.row == 0 {
      performSegue(withIdentifier: "setDate", sender: "start")
    }
    if indexPath.section == 1 && indexPath.row == 1 {
      performSegue(withIdentifier: "setDate", sender: "end")
    }
    if indexPath.section == 2 {
      performSegue(withIdentifier: "regions", sender: nil)
    }
    if indexPath.section == 3 {
      performSegue(withIdentifier: "about", sender: nil)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "setDate" {
      
     if let controller  = segue.destination as? DateController {
        
        controller.mode = sender as! String?
      }
      
    }
  }
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
 
}
