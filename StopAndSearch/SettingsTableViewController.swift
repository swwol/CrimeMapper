//
//  SettingsTableViewController.swift
//  StopAndSearch
//
//  Created by edit on 21/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

protocol SettingsTableViewControllerDelegate {
  
  func goTo(_ destination: String)
  
}


class SettingsTableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {


  var startMonth: Int = 0
  var startYear: Int = 0
  var endMonth: Int = 0
  var endYear: Int = 0
  var monthLastUpdated: Int = 0
  var yearLastUpdated: Int = 0
  var neighbourhoodID: String?
  let defaults = UserDefaults.standard
  var delegate: SettingsTableViewControllerDelegate?
  var destination : String?
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      titleLabel.adjustsFontSizeToFitWidth = true
      titleLabel.minimumScaleFactor = 0.5

  //   tableView.contentInset = UIEdgeInsets(top: 60, left: 0 , bottom: 0 , right: 0)
      let headerCellNib = UINib(nibName: "CustomHeaderCell", bundle: nil)
      tableView.register(headerCellNib, forCellReuseIdentifier: "HeaderCell")
      }
  
  override func viewWillAppear(_ animated: Bool) {
    
    //try reading startDate and endDate
    destination = nil
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

     func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if section == 1 {
        return 2
      } else {
        return 1
      }
    }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 34
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 60
  }
  
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
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
    cell.accessoryType = .disclosureIndicator
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
  
  // item selected
  
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.section == 0 {
      
  destination = "categories"
  
    }
    if indexPath.section == 1 && indexPath.row == 0 {
      destination = "startDate"
    }
    if indexPath.section == 1 && indexPath.row == 1 {
    destination = "endDate"
    }
    if indexPath.section == 2 {
      destination = "regions"
    }
    if indexPath.section == 3 {
      destination = "about"
    }
  self.dismiss(animated: true, completion: tellToGo)
  }
  
  func tellToGo() {
    if let d = destination {
      delegate?.goTo(d)
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
