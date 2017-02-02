//
//  SetDateMenuControllerViewController.swift
//  StopAndSearch
//
//  Created by edit on 02/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit



class SetDateMenuController: UIViewController {


  let containView = TouchContainer(frame: CGRect(x: 0, y: 0, width: 90, height: 40))
  let label = UILabel(frame: CGRect(x: 25, y: 0, width: 70, height: 40))
  let imageview = UIImageView(frame:CGRect(x: 0, y: 10, width:20, height: 20))

  
    override func viewDidLoad() {
        super.viewDidLoad()

      self.view  = containView
   
   
      label.font = label.font.withSize(12)
      label.textColor = UIColor.white
      label.textAlignment = NSTextAlignment.left
      containView.addSubview(label)
      imageview.image = UIImage(named: "linecal")
      imageview.image = imageview.image!.withRenderingMode(.alwaysTemplate)
      imageview.tintColor = UIColor.white
      imageview.contentMode = UIViewContentMode.scaleAspectFill
      containView.addSubview(imageview)
      
      self.view.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func setText (_ text:String) {
    
    print ("ok here i am")
    
    self.label.text = text
    
  }
  
  func setDate(month: Int?, year: Int?) {
    // set date from last data available API call
    if let m = month, let y = year {
      self.label.text = "\(Months.months[m-1])-\(y)"
    } else {
      self.label.text = "all dates"
    }
  }
  func setDate(date:MonthYear?){
    //set date from date picker
    if let d = date {
      self.label.text = "\(d.monthName)-\(d.yearAsString)"
    }else {
      self.label.text = "all dates"
    }
  }
  

}
