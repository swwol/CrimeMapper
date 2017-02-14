//
//  CoordinateCell.swift
//  StopAndSearch
//
//  Created by edit on 12/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class CoordinateCell: UITableViewCell {


  @IBOutlet weak var latValue: UILabel! 
  @IBOutlet weak var longValue: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
