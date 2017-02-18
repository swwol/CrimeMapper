//
//  CustomHeaderCell.swift
//  StopAndSearch
//
//  Created by edit on 10/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

protocol CustomHeaderCellDelegate {
  
  func switched(section: Int, value: Bool)
  
}

class CustomHeaderCell: UITableViewCell {
  
  var mySection: Int?
  var delegate: CustomHeaderCellDelegate?

  @IBOutlet weak var categorySwitch: UISwitch!
  
  @IBAction func categorySwitched(_ sender: UISwitch) {
    print ("section",mySection!, "value", sender.isOn)
    delegate?.switched(section: mySection ?? -1 , value: sender.isOn)
    
  }
  
  @IBOutlet weak var bg: UIView!
  
  @IBOutlet weak var categoryTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      self.categoryTitle.textColor = UIColor.flatGrayDark
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
