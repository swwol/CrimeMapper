//
//  DetailViewController.swift
//
//
//  Created by edit on 23/01/2017.
//
//

import UIKit

class DetailViewController: UIViewController,InitialisesExtendedNavBar {
  
  //propertieas to initialise xnavbar with if vc is navigated to
  var extendedNavBarColor = UIColor.flatMintDark.withAlphaComponent(0.33)
  var extendedNavBarMessage =  ""
  var extendedNavBarShouldShowDate = false
  var extendedNavBarFontSize: CGFloat  = 14
  var extendedNavBarFontColor = UIColor.flatBlackDark
  var extendedNavBarIsHidden = false
  //
  @IBOutlet weak var tableView: UITableView!
  
  var data : SearchResult?
  var dataArray = [(catTitle: String, catContents: [String])]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.contentInset = UIEdgeInsets(top: 60, left: 0 , bottom: 0 , right: 0)
    let cellNib = UINib(nibName: "CrimeDetail", bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: "CrimeDetail")
    let headerCellNib = UINib(nibName: "CustomHeaderCell", bundle: nil)
    tableView.register(headerCellNib, forCellReuseIdentifier: "HeaderCell")
    //get data into array
    putDataInArray()
   }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else {
      return dataArray.count
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! CustomHeaderCell
    cell.categoryTitle.text = ""
    cell.bg.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    if cell.categorySwitch != nil {
      cell.categorySwitch.removeFromSuperview()
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 0
    } else {
      return  34
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    if indexPath.section == 0 {
      return 120
    }
    else {
      return 44
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 && indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "CrimeDetail", for: indexPath) as! CrimeDetail
      cell.catView.backgroundColor = data!.color!
      cell.catView.layer.cornerRadius = cell.catView.frame.size.width/2
      cell.crimeLabel.text = data!.title
      cell.dateLabel.text = data!.subtitle!
      cell.streetLabel.text  = data!.street!
      cell.streetLabel.textColor  =  UIColor.init(complementaryFlatColorOf: UIColor.flatMintDark)
      cell.coordLabel.text = "lat \(data!.latitudeString!) long \(data!.longitudeString!)"
      cell.coordLabel.textColor = .darkGray
      return cell
    } else {
      
      let cell: UITableViewCell = {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") else {
          // Never fails:
          return UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "UITableViewCell")
        }
        return cell
      }()
      
      cell.detailTextLabel?.numberOfLines = 0
      
      let element = dataArray[indexPath.row]
      
      if ( element.catTitle == "date") {
   
        cell.textLabel?.text = "date"
        cell.detailTextLabel?.text =  MonthYear(date: element.catContents[0]).getDateAsString()
        return cell
        
      } else if element.catTitle == "coordinates" {
        cell.textLabel?.text = element.catTitle
        cell.detailTextLabel?.text = "\(element.catContents[0]),\(element.catContents[1])"
        return cell
        
      } else if element.catTitle == "outcome date" {
        let date =   MonthYear(date : element.catContents[0]).getDateAsString()
        cell.textLabel?.text = "outcome date"
        cell.detailTextLabel?.text = date
        return cell
      } else {
        cell.textLabel?.text = element.catTitle
        cell.detailTextLabel?.text = element.catContents[0]
        return cell
      }
    }
  }
  
  
  func putDataInArray() {
    
    // if im a crime - i have category (title), date, coodinate, street, context. outcome, outcomedate
    //get date:
    if let d = data!.month, d != "" {
      let date = (catTitle: "date", catContents: [d] )
      dataArray.append(date)
    }
    //get coordinate:
    if let lat = data!.latitudeString, let long = data!.longitudeString, lat != "" {
      let coordinates = (catTitle: "coordinates", catContents: [lat,long] )
      dataArray.append(coordinates)
    }
    //get street:
    if let street = data!.street, street != "" {
      let s = (catTitle: "street", catContents: [street] )
      dataArray.append(s)
    }
    //get context:
    if let context = data!.context, context != "" {
      let c = (catTitle: "context", catContents: [context] )
      dataArray.append(c)
    }
    if let outcome = data!.outcome, outcome != "" {
      let o = (catTitle: "outcome", catContents: [outcome] )
      dataArray.append(o)
    }
    if let outcomeDate = data!.outcome_date, outcomeDate != "" {
      let od = (catTitle: "outcome date", catContents: [outcomeDate] )
      dataArray.append(od)
    }
  }
}

