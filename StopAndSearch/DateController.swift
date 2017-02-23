//
//  DateController.swift
//  StopAndSearch
//
//  Created by edit on 21/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class DateController: UIViewController {
  
  var pickerData = [ [String](), [String]() ]
  let defaults = UserDefaults.standard
  var startMonth: Int = 0
  var startYear: Int = 0
  var endMonth: Int = 0
  var endYear: Int = 0
  var monthLastUpdated: Int = 0
  var yearLastUpdated: Int = 0
  var mode: String?

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
        setToDate(MonthYear(month: monthLastUpdated - 1, year: yearLastUpdated), anim: true)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("loaded with mode \(mode!)")
    doneButton.layer.cornerRadius = 10
    setToLatestButton.layer.cornerRadius = 10
    readData()
    initiatePicker()
    datePicker.delegate = self
    datePicker.dataSource = self
    self.view.backgroundColor = .flatWhite
    doneButton.tintColor = .flatMintDark
   }
  
  override func viewWillAppear(_ animated: Bool) {
    readData()
    initiatePicker()
    datePicker.reloadAllComponents()
    //set picker to startMonth and startYear if set
    if startMonth != 0 {
      setToDate(MonthYear(month: startMonth - 1, year: startYear), anim: false)
    } else {
      setToDate(MonthYear(month: monthLastUpdated - 1, year: yearLastUpdated), anim: false)
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
  
  func initiatePicker() {
    
    pickerData[0]  = Months.months
    // should be years 2010 - yearlastupdated
    pickerData[1] = []
    for y in 2010...yearLastUpdated {
      pickerData[1].append("\(y)")
    }
  }
  
  func setToDate(_ date:MonthYear, anim: Bool) {
  
      datePicker.selectRow(date.month, inComponent: 0, animated: anim)
      datePicker.selectRow(date.year - 2010, inComponent: 1, animated: anim)
  }
  
  func validateSaveAndDismiss() {
    let month  = datePicker.selectedRow(inComponent: 0) + 1
    let yearAsString = pickerData[1][datePicker.selectedRow(inComponent: 1)]
    let year = Int(yearAsString)
    //check if chosen date for startdate is before last date updated
    if year == yearLastUpdated && month > monthLastUpdated {
      showDateIsLaterThanLatestDataAlert()
    } else {
      // save date to start date and dissmiss
      defaults.set(month, forKey:"startMonth")
      defaults.set(year, forKey:"startYear")
      
      if let nav = navigationController {
        nav.popViewController(animated: true)
      } else {
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  func showDateIsLaterThanLatestDataAlert() {
    let alert = UIAlertController(title: "Start date is later than newest data",message:"Latest data available is for \(Months.months[monthLastUpdated - 1]) \(yearLastUpdated).", preferredStyle: .alert)
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





