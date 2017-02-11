//
//  ClusterInfoCell.swift
//  StopAndSearch
//
//  Created by edit on 11/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class ClusterInfoCell: UITableViewCell {

  @IBOutlet weak var streetLabel: UILabel!
  @IBOutlet weak var catLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var catView: UIView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
     
      let myCustomSelectionColorView = UIView()
      myCustomSelectionColorView.backgroundColor = UIColor.flatMint.withAlphaComponent(0.3)
      selectedBackgroundView = myCustomSelectionColorView

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
       

      let color = catView.backgroundColor
      super.setSelected(selected, animated: animated)
      
      if(selected) {
        catView.backgroundColor = color
      }
    }
  

  
  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    let color = catView.backgroundColor
    super.setHighlighted(highlighted, animated: animated)
    
    if(highlighted) {
      catView.backgroundColor = color
    }
  }
    
}
