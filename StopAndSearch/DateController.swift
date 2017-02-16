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
  var currentDate: MonthYear?
  var delegate: DateControllerDelegate?
  let pickerData =  [Months.months,["2014","2015","2016"]]
 
  
  @IBAction func didPressDone(_ sender: Any) {
  }
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var switchStatusLabel: UILabel!
  @IBOutlet weak var instructionsLabel: UILabel!
 
  @IBAction func didSetDate(_ sender: Any) {
  }
  @IBOutlet weak var setDateSwitch: UISwitch!
  @IBAction func setDate(_ sender: UIButton) {
    
    let month  = datePicker.selectedRow(inComponent: 0)
   // let year  = datePicker.selectedRow(inComponent: 1)
    let yearAsString = pickerData[1][datePicker.selectedRow(inComponent: 1)]
    let year = Int(yearAsString)
    let date = MonthYear(month:month,  year : year! )
    delegate?.didSetDate(date: date)
    self.dismiss(animated: true, completion: nil)
    
  }
  @IBOutlet weak var datePicker: UIPickerView!
  
    override func viewDidLoad() {
      
      super.viewDidLoad()
   
      datePicker.delegate = self
      datePicker.dataSource = self
      self.view.backgroundColor = .flatWhite
     doneButton.tintColor = .flatMintDark
     self.setToDate(currentDate)
     }
  
  func setToDate(_ date:MonthYear?) {
    if let d = date {
      datePicker.selectRow(d.month, inComponent: 0, animated: false)
      datePicker.selectRow(d.year - 2014, inComponent: 1, animated: false)
    }
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
  
  /*func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[component][row]
  }*/
  
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    
  
    return NSAttributedString(string:  pickerData[component][row] , attributes: [NSForegroundColorAttributeName:UIColor.flatBlack])
   

  }
 /*
  func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
   // if chose year 2014, set month to december as no data for other months available
    print (row, component)
    
    if component == 1 && row == 0 {
      pickerView.selectRow(11, inComponent: 0, animated: true)
    }
  }*/
}
