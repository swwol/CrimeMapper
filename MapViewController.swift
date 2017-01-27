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
import CoreLocation


class MapViewController: UIViewController, CLLocationManagerDelegate {
  
  var searchResults = [SearchResult]()
  var mapAnnotations = [MapAnnotation]()
  let locationManager = CLLocationManager()
  var location: CLLocation?
  var updatingLocation = false
  var lastLocationError: Error?
  
  @IBAction func getMyLocation(_ sender: UIBarButtonItem) {
    // authorise
    
    let authStatus = CLLocationManager.authorizationStatus()
    if authStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    
    if authStatus == .denied || authStatus == .restricted {
      showLocationServicesDeniedAlert()
      return
    }
    
   startLocationManager()
  }
  
  @IBAction func ItemPressed(_ sender: UIBarButtonItem) {
    
    print ("item button pressed")
    
    // get coordinates of the corners
    
    let region  = mapView.region
    let centre  =  region.center
    let span = region.span
    let ne = CLLocationCoordinate2DMake(centre.latitude + span.latitudeDelta / 2.0, centre.longitude - span.longitudeDelta / 2.0)
    let se = CLLocationCoordinate2DMake(centre.latitude - span.latitudeDelta / 2.0, centre.longitude - span.longitudeDelta / 2.0)
    let nw = CLLocationCoordinate2DMake(centre.latitude + span.latitudeDelta / 2.0, centre.longitude + span.longitudeDelta / 2.0)
    let sw = CLLocationCoordinate2DMake(centre.latitude - span.latitudeDelta / 2.0, centre.longitude + span.longitudeDelta / 2.0)
    
    
    let necornerAnnotation  = MapAnnotation(lat: "\(ne.latitude)", long: "\(ne.longitude)", title:"ne corner", subtitle: "oh yeah")
    let secornerAnnotation  = MapAnnotation(lat: "\(se.latitude)", long: "\(se.longitude)", title:"se corner", subtitle: "oh yeah")
    let nwcornerAnnotation  = MapAnnotation(lat: "\(nw.latitude)", long: "\(nw.longitude)", title:"nw corner", subtitle: "oh yeah")
    let swcornerAnnotation  = MapAnnotation(lat: "\(sw.latitude)", long: "\(sw.longitude)", title:"sw corner", subtitle: "oh yeah")
    
    mapView.addAnnotations([necornerAnnotation, secornerAnnotation,swcornerAnnotation,nwcornerAnnotation])
    
    
    
    

    
    
  }
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
    let pinView = MKAnnotationView(annotation: annotation,reuseIdentifier: identifier)
      pinView.isEnabled = true
      pinView.canShowCallout = true
     // pinView.animatesDrop = false
      let rightButton = UIButton(type: .detailDisclosure)
      rightButton.addTarget(self,action: #selector(showDetails),for: .touchUpInside)
      pinView.rightCalloutAccessoryView = rightButton
      pinView.image = UIImage(named: "mantest")
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
  
  func showLocationServicesDeniedAlert() {
    let alert = UIAlertController(title: "Location Services Disabled",message:"Please enable location services for this app in Settings.", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    present(alert, animated: true, completion: nil)
  }
  
  
  // MARK: - CLLocationManagerDelegate
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print ("fail \(error)")
    
    if (error as NSError).code == CLError.locationUnknown.rawValue {
      return
    }
    lastLocationError = error
    print ("alert error")
    
    stopLocationManager()
  }
  
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
      updatingLocation = true
    }
  }
  
  func stopLocationManager() {
    if updatingLocation {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updatingLocation = false
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    
    if newLocation.timestamp.timeIntervalSinceNow < -5 {
      return
    }
    
    if newLocation.horizontalAccuracy < 0 {
      return
    }
    
    if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
      // 4
      lastLocationError = nil
      location = newLocation
      if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
        print("*** We're done!")
        let center = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)

        stopLocationManager()
      }
    }
    }
}
