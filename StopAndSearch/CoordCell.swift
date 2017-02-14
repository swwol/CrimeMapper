//
//  CoordCell.swift
//  StopAndSearch
//
//  Created by edit on 13/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class CoordCell: UITableViewCell {

  @IBOutlet weak var bottomLabel: UILabel!
  @IBOutlet weak var topLabel: UILabel!
  @IBOutlet weak var icon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
