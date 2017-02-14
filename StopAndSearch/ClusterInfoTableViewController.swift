//
//  ClusterInfoTableViewController.swift
//  StopAndSearch
//
//  Created by edit on 03/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import UIKit

class ClusterInfoTableViewController: UITableViewController {
  
  var cluster: FBAnnotationCluster?
  var clusterContents = [[SearchResult]]()
  var sectionTitles = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.contentInset = UIEdgeInsets(top: 60, left: 0 , bottom: 0 , right: 0)
    //register category cell
    let cellNib = UINib(nibName: "ClusterInfoCell", bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: "ClusterInfoCell")
   //and headercell
    let headerCellNib = UINib(nibName: "CustomHeaderCell", bundle: nil)
    tableView.register(headerCellNib, forCellReuseIdentifier: "HeaderCell")

    
    if let c = cluster {
      let searchResults  = c.annotations as! [SearchResult]
      
      for type in Categories.types {
        print (type)
        let filteredByType = searchResults.filter{Categories.categoryDict[type]!.contains($0.title!)}
        if !filteredByType.isEmpty{
          clusterContents.append(filteredByType)
          sectionTitles.append(type)
        }
      }
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return clusterContents.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return clusterContents[section].count
  }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClusterInfoCell", for: indexPath) as! ClusterInfoCell
  

      let resultToDisplay  = clusterContents[indexPath.section][indexPath.row]
      cell.tintColor = UIColor.darkGray
      cell.catLabel.text = resultToDisplay.title!
      cell.dateLabel.text = resultToDisplay.subtitle!
      cell.dateLabel.textColor = .darkGray
      cell.streetLabel.text = resultToDisplay.street!
      cell.streetLabel.textColor = UIColor(complementaryFlatColorOf: .flatMintDark)
      cell.catView.backgroundColor = resultToDisplay.color!
      cell.catView.layer.cornerRadius  = cell.catView.frame.size.width/2
      cell.accessoryType = .disclosureIndicator
      return cell
    }
   
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    print ("selected cell at indexpath \(indexPath.row)" )
    
    //segue to detail view
    
    performSegue(withIdentifier: "showDetail", sender: clusterContents[indexPath.section][indexPath.row])
    
  }
  
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }

  
  /*override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionTitles[section]
  }*/
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! CustomHeaderCell
    cell.categoryTitle.text = sectionTitles[section]
    
    cell.bg.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    if cell.categorySwitch != nil {
    cell.categorySwitch.removeFromSuperview()
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 34
  }


  

  // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
      if segue.identifier  == "showDetail" {
        let controller = segue.destination as! DetailViewController
        controller.data = sender as? SearchResult
      }
  
  }
 
}
