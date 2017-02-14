//
//  ContentCell.swift
//  StopAndSearch
//
//  Created by edit on 13/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class ContentCell: UITableViewCell {

  @IBOutlet weak var contentLabel: UILabel!
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
