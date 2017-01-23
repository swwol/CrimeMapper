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
  let pickerData =  [["Jan","Feb","March","April","May","June","July","Aug","Sep","Oct","Nov","Dec"],["2014","2015","2016"]]
 
  
  @IBAction func setDate(_ sender: UIButton) {
    
    let month  = datePicker.selectedRow(inComponent: 0)
    let year  = datePicker.selectedRow(inComponent: 1)
    let monthName  = pickerData[0][month]
    let date = MonthYear(month:month,  year : year, monthName : monthName )
    delegate?.didSetDate(date: date)
    self.dismiss(animated: true, completion: nil)
    
  }
  @IBOutlet weak var datePicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
      datePicker.delegate = self
      datePicker.dataSource = self
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
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[component][row]
  }
  
  func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
   // if chose year 2014, set month to december as no data for other months available
    print (row, component)
    
    if component == 1 && row == 0 {
      pickerView.selectRow(11, inComponent: 0, animated: true)
    }
  }
}
