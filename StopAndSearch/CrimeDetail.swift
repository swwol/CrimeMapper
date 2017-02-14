//
//  CrimeDetail.swift
//  StopAndSearch
//
//  Created by edit on 12/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class CrimeDetail: UITableViewCell {
  @IBOutlet weak var crimeLabel: UILabel!
  @IBOutlet weak var catView: UIView!
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var coordLabel: UILabel!
  @IBOutlet weak var streetLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
