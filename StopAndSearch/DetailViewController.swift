//
//  DetailViewController.swift
//  
//
//  Created by edit on 23/01/2017.
//
//

import UIKit

class DetailViewController: UIViewController {

  @IBOutlet weak var typeLabel: UILabel!
  @IBOutlet weak var streetLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var genderLabel: UILabel!
  @IBOutlet weak var ageLabel: UILabel!
  @IBOutlet weak var ethnicityLabel: UILabel!
  
  @IBAction func closeButton(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  var data : SearchResult?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      typeLabel.text = data?.type ?? ""
      streetLabel.text = data?.street ?? ""
      dateLabel.text = data?.subtitle ?? ""
      genderLabel.text = data?.gender ?? ""
      ethnicityLabel.text = data?.ethnicity ?? ""
      ageLabel.text = data?.age ?? ""

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  }
