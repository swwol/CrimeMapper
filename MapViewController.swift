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
import Gloss


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
  var fbpins = [SearchResult]()
  let setDateMenuController = SetDateMenuController()
  
  var theMonth: Int? = nil
  var theYear: Int? = nil
  var monthYear: MonthYear? = nil
  
  var readyToSearch = false
  var selectedCategories: [Bool]?
  
  @IBAction func adjustSettings(_ sender: UIBarButtonItem) {
    
    // load the settings screen with date
    performSegue(withIdentifier: "loadControls", sender: selectedCategories)
    
    
  }
  
  @IBOutlet weak var toolbar: UIToolbar!
  
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
    
    guard readyToSearch else {
      return
    }
    
    let region  = mapView.region
    let centre  =  region.center
    let span = region.span
    //get corners of region
    let ne = CLLocationCoordinate2DMake(centre.latitude + span.latitudeDelta / 2.0, centre.longitude - span.longitudeDelta / 2.0)
    let se = CLLocationCoordinate2DMake(centre.latitude - span.latitudeDelta / 2.0, centre.longitude - span.longitudeDelta / 2.0)
    let nw = CLLocationCoordinate2DMake(centre.latitude + span.latitudeDelta / 2.0, centre.longitude + span.longitudeDelta / 2.0)
    let sw = CLLocationCoordinate2DMake(centre.latitude - span.latitudeDelta / 2.0, centre.longitude + span.longitudeDelta / 2.0)
    //now get data for region
    
   // clear fbpins array
    
    fbpins = []
    
    
    search.performSearch(coords: [ne,nw,sw,se], date: self.monthYear, categories: self.selectedCategories) {success in
      
      print ("ok")
      print ("got data for category \(Categories.categories[success.1])")
    
      self.generateFBAnnotations(results: success.0)
      self.myActivityIndicator.stopAnimating()
    }
  }
  
  func removeAnnotations() {
    print("removing annotations")
    fbpins = []
    clusteringManager.removeAll()
    clusteringManager.display(annotations: [], onMapView: self.mapView)
  }
  
  
  func generateFBAnnotations(results: [SearchResult]) {
   
    fbpins += results
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
  
  func getDateLastUpdated() {
   
    Alamofire.request("https://data.police.uk/api/crime-last-updated").responseJSON { response in
      if let JSON = response.result.value {
        print("JSON: \(JSON)")
        let parsedToDict = JSON as! [String:String]
        print (parsedToDict)
        if let date  = parsedToDict["date"] {
          let index = date.index(date.startIndex, offsetBy:4)
          let year = date.substring(to: index)
          self.theYear = Int(year)
          let monthStartIndex = date.index(date.startIndex, offsetBy:5)
          let monthEndIndex = date.index(date.startIndex, offsetBy: 7)
          let range = monthStartIndex..<monthEndIndex
          let month = date.substring(with: range)
          self.theMonth = Int(month)
          self.monthYear = MonthYear(month: self.theMonth! - 1, year: self.theYear! )
          print("\(self.theMonth)-\(self.theYear)")
         self.setDateMenuController.setDate(month: self.theMonth, year: self.theYear)
        }
      } else {
        self.theYear = nil; self.theMonth = nil
      }
      self.readyToSearch = true
      self.findAndDisplayDataPointsInVisibleRegion()
    }
  }
  
  
  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
   
    super.viewDidLoad()
    
    search.delegate = self
//appearance
    
    let barTintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
    toolbar.barTintColor=barTintColor

 //gesture recogniser to hide clusters/pins when zooming
    let zoom  = UIPinchGestureRecognizer ( target: self, action:  #selector(self.handleZoom(_:)))
    zoom.delegate = self
    mapView.addGestureRecognizer(zoom)
    mapView.isUserInteractionEnabled = true
//activity indicator
    myActivityIndicator.hidesWhenStopped = true
    myActivityIndicator.center = view.center
   view.addSubview(myActivityIndicator)
// set the date button in nav bar
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: setDateMenuController.view)
    let tc = setDateMenuController.view as! TouchContainer
    tc.delegate = self
//find date of latest data
    getDateLastUpdated()
   }
  
  
  func handleZoom( _ sender: UIPinchGestureRecognizer) {
    if (sender.state == UIGestureRecognizerState.began) {
      print("Zoom began")
      fbpins = []
      clusteringManager.removeAll()
      clusteringManager.display(annotations: fbpins, onMapView: mapView)
    }
  }
  
}
extension MapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    print ("region changed")
    findAndDisplayDataPointsInVisibleRegion()
  }
  
  
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
   if annotation is MKUserLocation {
      return nil
    }
    
    var reuseId = ""
    if annotation is FBAnnotationCluster {
 
      reuseId = "Cluster"
      var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
      if clusterView == nil {
        clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: FBAnnotationClusterViewConfiguration.default())
      (clusterView as! FBAnnotationClusterView).delegate = self
      } else {
        clusterView?.annotation = annotation
      }
      return clusterView
    } else {
      reuseId = "Pin"
      
      var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
      if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    
        pinView?.isEnabled = true
        pinView?.canShowCallout = true
        let rightButton = UIButton(type: .detailDisclosure)
        rightButton.tintColor = UIColor.gray
        let resultToDisplay = annotation as! SearchResult
        let i = fbpins.index(of: resultToDisplay)
        rightButton.tag = i!
        rightButton.addTarget(self,action: #selector(showDetails),for: .touchUpInside)

        pinView?.rightCalloutAccessoryView = rightButton
        
      
        pinView?.pinTintColor = resultToDisplay.color ?? UIColor.white
        let subtitleView = UILabel()
        subtitleView.font = subtitleView.font.withSize(10)
        subtitleView.textColor = UIColor.gray
        subtitleView.numberOfLines = 0
        subtitleView.text = annotation.subtitle!
        
        
        
        pinView!.detailCalloutAccessoryView = subtitleView
      } else {
        pinView?.annotation = annotation
        pinView?.pinTintColor = (annotation as! SearchResult).color
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
      controller.data = fbpins[sender as! Int]
    }
    if segue.identifier == "setDate" {
      let controller  = segue.destination as! DateController
      controller.delegate = self
      controller.currentDate = sender as! MonthYear?
    }
    if segue.identifier == "showClusterInfo" {
      let controller = segue.destination as! ClusterInfoTableViewController
      controller.cluster  = sender as? FBAnnotationCluster
    }
    
    if segue.identifier == "loadControls" {
      let controller = segue.destination as! ControlsTableViewController
      controller.checked = sender as! [Bool]?
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

extension MapViewController: TouchContainerDelegate {
  
  func touchContainerTouched(_ sender: TouchContainer) {
    print ("container was touched")
    self.performSegue(withIdentifier: "setDate", sender: self.monthYear)
    
  }
}

extension MapViewController: DateControllerDelegate {
  
  func didSetDate(date: MonthYear) {
    setDateMenuController.setDate(date: date)
    print ("new date is ", date)
    self.monthYear = date
    findAndDisplayDataPointsInVisibleRegion()
  }
}

extension MapViewController: FBAnnotationClusterViewDelegate {

  func showClusterInfo(for cluster: FBAnnotationCluster) {
    performSegue(withIdentifier: "showClusterInfo", sender: cluster)
  }
}

extension MapViewController: SearchDelegate {
  
  func searchStarted(for category: Int) {
  
    myActivityIndicator.startAnimating()
    print ("searching for cat \(category)")
  }
  
}

