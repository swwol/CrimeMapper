//
//  CategoryCell.swift
//  StopAndSearch
//
//  Created by edit on 09/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
  
  var overlay: UIView?

  @IBOutlet weak var typeLabel: UILabel!


  @IBOutlet weak var bg: UIView!


  @IBOutlet weak var categoryView: UIView!
  @IBOutlet weak var categoryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
     
      let myCustomSelectionColorView = UIView()
      myCustomSelectionColorView.backgroundColor = UIColor.flatMint.withAlphaComponent(0.3)
      selectedBackgroundView = myCustomSelectionColorView
    }

  override func setSelected(_ selected: Bool, animated: Bool) {
    let color = categoryView.backgroundColor
    super.setSelected(selected, animated: animated)
    
    if(selected) {
     categoryView.backgroundColor = color
    }
  }
  
  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    let color = categoryView.backgroundColor
    super.setHighlighted(highlighted, animated: animated)
    
    if(highlighted) {
      categoryView.backgroundColor = color
   }
  }

}
