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
import Alamofire


class MapViewController: UIViewController, CLLocationManagerDelegate {
  
  
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
  
  
  func changeDate( _ sender: UITapGestureRecognizer) {
    
    print("change date here")
    
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
    

    //test Alamofire here
    
    Alamofire.request("https://data.police.uk/api/crime-last-updated").responseJSON { response in
     
      
      print(response.request)  // original URL request
      print(response.response) // HTTP URL response
      print(response.data)     // server data
      print(response.result)
      
      if let JSON = response.result.value {
        print("JSON: \(JSON)")
        
        let parsedToDict = JSON as! [String:String]
        print (parsedToDict)
        
        if let date  = parsedToDict["date"] {
          let index = date.index(date.startIndex, offsetBy:4)
          let year = date.substring(to: index)
          print (year)
          
          let monthStartIndex = date.index(date.startIndex, offsetBy:5)
          let monthEndIndex = date.index(date.startIndex, offsetBy: 7)
          let range = monthStartIndex..<monthEndIndex
          
          let month = date.substring(with: range)
          
          print (month)
        }
      }
      
    }
    
    
  
  }
  
 
  
  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    let zoom  = UIPinchGestureRecognizer ( target: self, action:  #selector(self.handleZoom(_:)))
    zoom.delegate = self
    mapView.addGestureRecognizer(zoom)
    mapView.isUserInteractionEnabled = true
    
    super.viewDidLoad()

    myActivityIndicator.hidesWhenStopped = true
    myActivityIndicator.center = view.center
    view.addSubview(myActivityIndicator)
    
    let containView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 40))
    let label = UILabel(frame: CGRect(x: 25, y: 0, width: 70, height: 40))
    label.text = "Nov 2015"
  
    label.font = label.font.withSize(12)
   
    label.textAlignment = NSTextAlignment.left

    containView.addSubview(label)
    
    let imageview = UIImageView(frame:CGRect(x: 0, y: 10, width:20, height: 20))
    imageview.image = UIImage(named: "linecal")
    imageview.contentMode = UIViewContentMode.scaleAspectFill
    containView.addSubview(imageview)
    
    let tap = UITapGestureRecognizer(target: self, action:  #selector (self.changeDate (_:)))
    containView.addGestureRecognizer(tap)
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containView)
    
    
   }
  
  func loadAnnotations(resultArray: [SearchResult]) {
  
    removeAllAnotations()
    searchResults = resultArray
    mapView.addAnnotations(searchResults)
    
    
  }
  
  func handleZoom( _ sender: UIPinchGestureRecognizer) {
    if (sender.state == UIGestureRecognizerState.began) {
      print("Zoom began")
      fbpins = []
      clusteringManager.removeAll()
      clusteringManager.display(annotations: fbpins, onMapView: mapView)
    }
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
    
    guard annotation is FBAnnotationCluster || annotation is SearchResult else {
      return nil
    }
    
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


extension MapViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}

extension MapViewController: UISearchBarDelegate {
  
  
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

  
}
