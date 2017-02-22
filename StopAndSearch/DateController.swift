//
//  DateController.swift
//  StopAndSearch
//
//  Created by edit on 21/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

protocol DateControllerDelegate: class {
  
  func didSetDate(date: MonthYear)
}

class DateController: UIViewController {
  
  var delegate: DateControllerDelegate?
 
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
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    print("loaded with mode \(mode!)")
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
      setToDate(MonthYear(month: startMonth, year: startYear))
    } else {
      setToDate(MonthYear(month: monthLastUpdated, year: yearLastUpdated))
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
  
  func setToDate(_ date:MonthYear) {
  
     // datePicker.selectRow(d.month, inComponent: 0, animated: false)
     // datePicker.selectRow(d.year - 2014, inComponent: 1, animated: false)
  }

  func validateSaveAndDismiss() {
    let month  = datePicker.selectedRow(inComponent: 0)
    let yearAsString = pickerData[1][datePicker.selectedRow(inComponent: 1)]
    let year = Int(yearAsString)
    let date = MonthYear(month:month,  year : year! )
    delegate?.didSetDate(date: date)
    self.dismiss(animated: true, completion: nil)
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





