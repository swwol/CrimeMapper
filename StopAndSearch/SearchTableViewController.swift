//
//  SearchTableViewController.swift
//  StopAndSearch
//
//  Created by edit on 21/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {
  
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
   var address: Address?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
      if segue.identifier == "SetAddress" {
        let controller = segue.destination as! AddressController
        controller.delegate = self        
      }
      
      if segue.identifier == "SetDate" {
  //      let controller = segue.destination as! DateController
     //   controller.delegate = self
      }
  }
}

extension SearchTableViewController: AddressControllerDelegate {
  
  func didSetAddress(address: Address) {
    
    self.address = address
    print ("Address set", self.address!.fullAddress ?? "address not set")
    
    if let a  = self.address!.fullAddress {
      addressLabel.text! = a
    }
  }
}
