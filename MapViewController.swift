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


class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
  
  
  var searchResults = [SearchResult]()
  let locationManager = CLLocationManager()
  var location: CLLocation?
  var updatingLocation = false
  var lastLocationError: Error?
  let search = Search()
  var searchController:UISearchController!
  var localSearchRequest:MKLocalSearchRequest!
  var localSearch:MKLocalSearch!
  var localSearchResponse:MKLocalSearchResponse!
  var error:NSError!
  let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  let clusteringManager  = FBClusteringManager()
  var fbpins = [FBAnnotation]()
  
 // perform local search
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
    
    searchBar.resignFirstResponder()
    dismiss(animated: true, completion: nil)
    
    localSearchRequest = MKLocalSearchRequest()
    localSearchRequest.naturalLanguageQuery = searchBar.text
    localSearch = MKLocalSearch(request: localSearchRequest)
    localSearch.start {
      (localSearchResponse, error) -> Void in
      
      if localSearchResponse == nil{
        let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
      }
      self.mapView.setRegion(localSearchResponse!.boundingRegion, animated: true)
    }
  }
  
  //show search bar
  
  @IBAction func searchMap(_ sender: UIBarButtonItem) {
    
    searchController = UISearchController(searchResultsController: nil)
    searchController.hidesNavigationBarDuringPresentation = false
    self.searchController.searchBar.delegate = self
    present(searchController, animated: true, completion: nil)
    
  }
  
  // go to my location
  
  @IBAction func getMyLocation(_ sender: UIBarButtonItem) {
    
    // authorise
    
    print("getting location")
    
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
  
  // find  and display datapoints within viewable region
  
  func findAndDisplayDataPointsInVisibleRegion() {
    
    myActivityIndicator.startAnimating()
    
    let region  = mapView.region
    let centre  =  region.center
    let span = region.span
    //get corners of region
    let ne = CLLocationCoordinate2DMake(centre.latitude + span.latitudeDelta / 2.0, centre.longitude - span.longitudeDelta / 2.0)
    let se = CLLocationCoordinate2DMake(centre.latitude - span.latitudeDelta / 2.0, centre.longitude - span.longitudeDelta / 2.0)
    let nw = CLLocationCoordinate2DMake(centre.latitude + span.latitudeDelta / 2.0, centre.longitude + span.longitudeDelta / 2.0)
    let sw = CLLocationCoordinate2DMake(centre.latitude - span.latitudeDelta / 2.0, centre.longitude + span.longitudeDelta / 2.0)
    //now get data for region
   
    search.performSearch(coords: [ne,nw,sw,se], date: nil) {success in
      switch self.search.state {
      case .noResults:
        print ("no results")
      case .results(let resultArray):
        
        print ("returned \(resultArray.count) results")
       /*
        for (i,result) in resultArray.enumerated() {
          
          print ("processing result \(i)")
          
          if !self.searchResults.contains(result) {
            self.searchResults.append(result)
            self.addAnnotation(annotation: result.mapAnnotation)
          }
        }
 */
        
        // remove all anotations
      
        // instead of loding annotations  - generate FBAnnotations from results
        
     //   self.loadAnnotations(resultArray: resultArray)
        
       self.generateFBAnnotations(results: resultArray)

      default:
        return
      }
     self.myActivityIndicator.stopAnimating()
    }
  }
  
  func generateFBAnnotations(results: [SearchResult]) {
    fbpins = []
    for result in results {
      
      let fb = FBAnnotation()
      fb.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
      fb.title = result.title
      fbpins.append(fb)

    }
    clusteringManager.removeAll()
    clusteringManager.add(annotations: fbpins)
    DispatchQueue.global(qos: .userInitiated).async {
      let mapBoundsWidth = Double(self.mapView.bounds.size.width)
      let mapRectWidth = self.mapView.visibleMapRect.size.width
      let scale = mapBoundsWidth / mapRectWidth
      
      let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale:scale)
      
      DispatchQueue.main.async {
        self.clusteringManager.display(annotations: annotationArray, onMapView:self.mapView)
      }
    }
  }
  
  
  @IBAction func ItemPressed(_ sender: UIBarButtonItem) {
    
  findAndDisplayDataPointsInVisibleRegion()
  
  }
  
  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    myActivityIndicator.hidesWhenStopped = true
    myActivityIndicator.center = view.center
    view.addSubview(myActivityIndicator)
   }
  
  func loadAnnotations(resultArray: [SearchResult]) {
  
    removeAllAnotations()
    searchResults = resultArray
    mapView.addAnnotations(searchResults)
    
    
  }
 /*
  func addAnnotation( annotation: SearchResult) {
     mapView.addAnnotation(annotation)
    }
  */
  func removeAllAnotations() {
   
    mapView.removeAnnotations(searchResults)
    searchResults = []
    
  }
  
}
extension MapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    print ("region changed")
    findAndDisplayDataPointsInVisibleRegion()
  }
  
  func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    
    print ("WILL CHANGE")
    fbpins = []
    clusteringManager.removeAll()
    clusteringManager.display(annotations: fbpins, onMapView: mapView)
    }

  
/*func mapView(_ mapView: MKMapView,viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation is SearchResult else {
      return nil
    }
    
    let identifier = "Location"
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
       if annotationView == nil {
    let pinView = MKPinAnnotationView(annotation: annotation,reuseIdentifier: identifier)
      pinView.isEnabled = true
      pinView.canShowCallout = true
     // pinView.animatesDrop = false
      let rightButton = UIButton(type: .detailDisclosure)
      rightButton.addTarget(self,action: #selector(showDetails),for: .touchUpInside)
      pinView.rightCalloutAccessoryView = rightButton
      annotationView = pinView
    }
 //   if let annotationView = annotationView {
 //     annotationView.annotation = annotation
   //   _ = annotationView.rightCalloutAccessoryView as! UIButton
     /* if let index = mapAnnotations.index(of: annotation as! MapAnnotation) {
        button.tag = index
      }*/
   // }
    return annotationView
  }*/
  
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    var reuseId = ""
    if annotation is FBAnnotationCluster {
      reuseId = "Cluster"
      var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
      if clusterView == nil {
        clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: FBAnnotationClusterViewConfiguration.default())
      } else {
        clusterView?.annotation = annotation
      }
      return clusterView
    } else {
      reuseId = "Pin"
      var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
      if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.green
      } else {
        pinView?.annotation = annotation
      }
      return pinView
    }
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
    
    print ("starting mananger")
    if CLLocationManager.locationServicesEnabled() {
 
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
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
    print ("here")
    let newLocation = locations.last!
    if newLocation.timestamp.timeIntervalSinceNow < -5 {
      print("too old")
      return
    }
    
    if newLocation.horizontalAccuracy < 0 {
      print ("less than 0")
      return
    }
    
    if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
      // 4
      
      print ("improving")
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
