//
//  AddressController.swift
//  StopAndSearch
//
//  Created by edit on 20/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

protocol AddressControllerDelegate: class {
  
  func didSetAddress(address: Address)
  
}

class AddressController: UIViewController {
  
  var address =  Address()
  var delegate: AddressControllerDelegate?
//to do  - set a delegate back to main view controller

  @IBOutlet weak var street: UITextField!
  @IBOutlet weak var city: UITextField!
  @IBOutlet weak var postcode: UITextField!
  
  @IBAction func findAddresss(_ sender: UIButton) {
    
    if street.text! != "" {
      address.street = street.text!
    }
    if city.text! != "" {
      address.city = city.text!
    }
    if postcode.text! != "" {
      address.postcode = postcode.text!
    }
    
    delegate?.didSetAddress(address: address)
    self.dismiss(animated: true, completion: nil)
  }
  
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
