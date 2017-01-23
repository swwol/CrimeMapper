//
//  MapViewController.swift
//  StopAndSearch
//
//  Created by edit on 23/01/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class MapViewController: UIViewController {
  
  var searchResults = [SearchResult]()
  var mapAnnotations = [MapAnnotation]()
  
  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapAnnotations = []
    loadAnnotations()
   }
  
  func loadAnnotations() {
    for s in searchResults {
      mapAnnotations.append(s.mapAnnotation)
      mapView.addAnnotation(s.mapAnnotation)
    }
    // zoom to fit all pins
    mapView.showAnnotations(mapView.annotations, animated: true)
  }
}

extension MapViewController: MKMapViewDelegate {
  
  
  func mapView(_ mapView: MKMapView,viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation is MapAnnotation else {
      return nil
    }
    
    let identifier = "Location"
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
       if annotationView == nil {
    let pinView = MKPinAnnotationView(annotation: annotation,reuseIdentifier: identifier)
      pinView.isEnabled = true
      pinView.canShowCallout = true
      pinView.animatesDrop = false
      let rightButton = UIButton(type: .detailDisclosure)
      rightButton.addTarget(self,action: #selector(showDetails),for: .touchUpInside)
      pinView.rightCalloutAccessoryView = rightButton
      annotationView = pinView
    }
    if let annotationView = annotationView {
      annotationView.annotation = annotation
      let button = annotationView.rightCalloutAccessoryView as! UIButton
      if let index = mapAnnotations.index(of: annotation as! MapAnnotation) {
        button.tag = index
      }
    }
    return annotationView
  }
  
  func showDetails(_ sender: UIButton) {
    performSegue(withIdentifier: "showDetail", sender: sender.tag)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      let controller = segue.destination as! DetailViewController
      controller.data = searchResults[sender as! Int]
    }
  }
  
}
