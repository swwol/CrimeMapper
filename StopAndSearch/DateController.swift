//
//  DateController.swift
//  StopAndSearch
//
//  Created by edit on 21/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class DateController: UIViewController, InitialisesExtendedNavBar {
  
  var extendedNavBarColor = UIColor.flatGray.withAlphaComponent(0.33)
  var extendedNavBarMessage =  "touch cluster of pin for info"
  var extendedNavBarShouldShowDate = true
  var extendedNavBarFontSize: CGFloat  = 12
  var extendedNavBarFontColor = UIColor.flatBlack
  var extendedNavBarIsHidden = true  //
  //
  var pickerData = [ [String](), [String]() ]
  let defaults = UserDefaults.standard
  var startMonth: Int = 0
  var startYear: Int = 0
  var endMonth: Int = 0
  var endYear: Int = 0
  var monthLastUpdated: Int = 0
  var yearLastUpdated: Int = 0
  var mode: String?
  //
  @IBAction func didPressDone(_ sender: Any) {
    validateSaveAndDismiss()
  }
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var instructionsLabel: UILabel!
  @IBOutlet weak var titleViewContainer: UIView!
  @IBOutlet weak var pickerContainer: UIView!
  @IBOutlet weak var instructionsContainer: UIView!
  @IBOutlet weak var datePicker: UIPickerView!
  @IBOutlet weak var setToLatestButton: UIButton!
  @IBAction func setToLatest(_ sender: UIButton) {
    
    if monthLastUpdated != 0 {
        setToDate(MonthYear(month: monthLastUpdated, year: yearLastUpdated), anim: true)
    }
  }
  @IBOutlet weak var startEndControl: UISegmentedControl!
  @IBAction func ModeChanged(_ sender: UISegmentedControl) {
    
    if sender.selectedSegmentIndex == 0 {
      self.mode = "start"
        } else {
      self.mode = "end"
    }
    setPickerDateForMode(mode: self.mode!, anim: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    startEndControl.tintColor = UIColor.flatMint
    
    doneButton.layer.cornerRadius = 10
    setToLatestButton.layer.cornerRadius = 10
    readData()
    initiatePickerData()
    datePicker.delegate = self
    datePicker.dataSource = self
    self.view.backgroundColor = .flatWhite
    doneButton.tintColor = .flatMintDark
   }
  
  override func viewWillAppear(_ animated: Bool) {
    readData()
    initiatePickerData()
    datePicker.reloadAllComponents()
    
    if let mode = self.mode {
      setPickerDateForMode(mode: mode)
    }
  }
  
  func setPickerDateForMode(mode : String, anim: Bool = false) {
    
    if mode == "start" {
      startEndControl.selectedSegmentIndex = 0
      //set picker to startMonth and startYear if set
      if startMonth != 0 {
        setToDate(MonthYear(month: startMonth, year: startYear), anim: anim)
      } else {
        setToDate(MonthYear(month: monthLastUpdated, year: yearLastUpdated), anim: anim)
      }
    }else if mode == "end" {
      startEndControl.selectedSegmentIndex = 1
      //set picker to endMonth and endYear if set
      if endMonth != 0 {
        setToDate(MonthYear(month: endMonth, year: endYear), anim: anim)
      } else {
        setToDate(MonthYear(month: monthLastUpdated, year: yearLastUpdated), anim: anim)
      }
    }
  }
  
  func readData() {
    startMonth  = defaults.integer(forKey: "startMonth")
    startYear  = defaults.integer(forKey: "startYear")
    endMonth  = defaults.integer(forKey: "endMonth")
    endYear  = defaults.integer(forKey: "endYear")
    monthLastUpdated = defaults.integer(forKey: "monthLastUpdated")
    yearLastUpdated = defaults.integer(forKey: "yearLastUpdated")
  }
  
  func initiatePickerData() {
    
    pickerData[0]  = Months.months
    // should be years 2010 - yearlastupdated
    pickerData[1] = []
    for y in 2010...yearLastUpdated {
      pickerData[1].append("\(y)")
    }
  }
  
  func setToDate(_ date:MonthYear, anim: Bool) {
  
      datePicker.selectRow(date.month - 1, inComponent: 0, animated: anim)
      datePicker.selectRow(date.year - 2010, inComponent: 1, animated: anim)
  }
  
  func validateSaveAndDismiss() {
    let month  = datePicker.selectedRow(inComponent: 0) + 1
    let yearAsString = pickerData[1][datePicker.selectedRow(inComponent: 1)]
    let year = Int(yearAsString)
    
    guard (year! <= yearLastUpdated && month <= monthLastUpdated)  else {
      showDateIsLaterThanLatestDataAlert()
      return
    }
    
    if let mode = self.mode {
      if mode == "start" {
        guard startDateIsValid (m:month,y:year!)  else {
          return
        }
        
        defaults.set(month, forKey:"startMonth")
        defaults.set(year, forKey:"startYear")
        goBack()
      } else if mode == "end" {
        
        guard  endDateIsValid(m:month,y:year!) else {
          return
        }
        defaults.set(month, forKey:"endMonth")
        defaults.set(year, forKey:"endYear")
        goBack()
      }
    }
  }
  
  func startDateIsValid(m:Int, y: Int) -> Bool {
    // start date is valid if it is before end date, or if no end date is set
    if   endMonth == 0 || (m <= endMonth && y <= endYear) {
      return true
    } else {
      showEndDateIsLaterThanStartDateAlert()
      return false
    }
  }
  
  func endDateIsValid(m:Int, y: Int) -> Bool {
    // end date is valid if it is after end date, and start date is set
    
    guard startMonth != 0 else {
      showNoStartDateSetAlert()
      return false
    }
    if  (m >= endMonth && y >= endYear) {
      return true
    } else {
      showEndDateIsLaterThanStartDateAlert()
      return false
    }
  }
  
  
  func goBack() {
    if let nav = navigationController {
      nav.popViewController(animated: true)
    } else {
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  func showNoStartDateSetAlert() {
    let alert = UIAlertController(title: "No start date set",message:"Set a start date before setting end date", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    present(alert, animated: true, completion: nil)
  }
  
  func showDateIsLaterThanLatestDataAlert() {
    let alert = UIAlertController(title: "Date is later than newest data",message:"Latest data available is for \(Months.months[monthLastUpdated - 1]) \(yearLastUpdated).", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    present(alert, animated: true, completion: nil)
  }
  
  func showEndDateIsLaterThanStartDateAlert() {
    let alert = UIAlertController(title: "Start date is later than end date",message:"Start date must be before end date", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    present(alert, animated: true, completion: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension DateController: UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return pickerData.count
  }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData[component].count
  }
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    return NSAttributedString(string:  pickerData[component][row] , attributes: [NSForegroundColorAttributeName:UIColor.flatBlack])
  }
}





