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

class MapViewController: UIViewController, CLLocationManagerDelegate, InitialisesExtendedNavBar {
  
  @IBAction func graphButtonPressed(_ sender: UIBarButtonItem) {
    self.performSegue(withIdentifier: "showGraphs", sender: fbpins)
  }
  //propertieas to initialise xnavbar with if vc is navigated to
  
  var extendedNavBarColor = UIColor.flatGray.withAlphaComponent(0.33)
  var extendedNavBarMessage =  "touch cluster of pin for info"
  var extendedNavBarShouldShowDate = true
  var extendedNavBarFontSize: CGFloat  = 12
  var extendedNavBarFontColor = UIColor.flatBlack
  var extendedNavBarIsHidden = false
  //
  
  let defaults = UserDefaults.standard
  
  var searchResults = [SearchResult]()
  let locationManager = CLLocationManager()
  var location: CLLocation?
  var updatingLocation = false
  var located = false
  var lastLocationError: Error?
  let search = Search()
  var searchController:UISearchController!
  var localSearchRequest:MKLocalSearchRequest!
  var localSearch:MKLocalSearch!
  var localSearchResponse:MKLocalSearchResponse!
  var error:NSError!
  
  let clusteringManager  = FBClusteringManager()
  var fbpins = [SearchResult]()
  let setDateMenuController = SetDateMenuController()
  
 
  var monthYear: MonthYear? = nil
  var readyToSearch = false
  var loader: Loader?
  
  var force: String?
  var neighbourhood : String?
  var sessionManager : SessionManager?
  lazy var slideInTransitioningDelegate = SlideInPresentationManager()
  
  
  @IBAction func adjustSettings(_ sender: UIBarButtonItem) {
    // load the settings screen with date
    performSegue(withIdentifier: "settings", sender: nil)
  }
  

  
  @IBOutlet weak var toolbar: UIToolbar!
  @IBAction func searchMap(_ sender: UIBarButtonItem) {
    searchController = UISearchController(searchResultsController: nil)
    searchController.hidesNavigationBarDuringPresentation = false
    // this is to make cursor not white!
    let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
    textFieldInsideSearchBar?.tintColor = UIColor.lightGray
    let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
    textFieldInsideSearchBarLabel?.text = "Search for UK address..."
    self.searchController.searchBar.delegate = self
    present(searchController, animated: true, completion: nil)
  }
  
  // go to my location
  @IBAction func getMyLocation(_ sender: UIBarButtonItem) {
    getLocation()
  }
  
  func getLocation() {
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
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    //put loader back in middle
    loader?.center = view.center
    findAndDisplayDataPointsInVisibleRegion()
  }
  
  // find  and display datapoints within viewable region
  func findAndDisplayDataPointsInVisibleRegion() {
    guard readyToSearch else {
      return
    }
    
    guard neighbourhood == nil else {
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
  
  search.performSearch(coords: [ne,nw,sw,se] ) {success in
      self.generateFBAnnotations(results: success.0)
 
    }
  }
  
  func getSearchNeighbourhoodID() {
    
    if let n = defaults.object(forKey: "neighbourhood"), let f = defaults.object(forKey: "force") {
      if let nUnwrapped = n as? String, let fUnwrapped = f as? String {
        neighbourhood = nUnwrapped
        force = fUnwrapped
      } else {
        neighbourhood = nil
        force  = nil
      }
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
        if let date  = parsedToDict["date"] {
          let formattedDate = MonthYear(date: date)
          // store this value on user defaults
          self.defaults.set(formattedDate.month, forKey: "monthLastUpdated")
          self.defaults.set(formattedDate.year, forKey: "yearLastUpdated")
          self.updateDateExtendedNavBarInfo()
        }
      }
      self.readyToSearch = true
      self.findAndDisplayDataPointsInVisibleRegion()
    }
  }
  
  func updateDateExtendedNavBarInfo() {
    let nav = self.navigationController as! ExtendedNavController
    nav.updateInfo()
  }
  
  @IBOutlet weak var mapView: MKMapView!
 
  override func viewDidLoad() {
    super.viewDidLoad()
   
    navigationController?.delegate = self
    search.delegate = self
    // go to users location on launch
    getLocation()
    //appearance
    let barTintColor = UIColor.flatMintDark
    toolbar.barTintColor=barTintColor
    //gesture recogniser to hide clusters/pins when zooming
    let zoom  = UIPinchGestureRecognizer ( target: self, action:  #selector(self.handleZoom(_:)))
    zoom.delegate = self
    mapView.addGestureRecognizer(zoom)
    mapView.isUserInteractionEnabled = true
    
      //find date of latest data
    getDateLastUpdated()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    // set values of neighbour and force
    getSearchNeighbourhoodID()
    
    print (force ?? "force not set", neighbourhood ?? "neigbourhood not set")
    
    
    updateDateExtendedNavBarInfo()
    
    if let n = neighbourhood, let f = force {
      
      findAndDisplayPointsInNeighbourhood(force: f, neighbourhood: n)
      
    } else {
    
    findAndDisplayDataPointsInVisibleRegion()
      
    }
  }
  

  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
   
    if overlay is MKPolygon {
      let renderer = MKPolygonRenderer(overlay: overlay)
      renderer.strokeColor = .flatOrange
      renderer.lineWidth = 2
      return renderer
    }
    
    return MKOverlayRenderer()
  }
  
  
  func  findAndDisplayPointsInNeighbourhood(force: String, neighbourhood: String) {
    
    guard readyToSearch else {
      return
    }

    guard self.neighbourhood != nil else {
      return
    }
    
    if (loader == nil) {
      loader = Loader(message: "loading data...")
      loader?.alpha = 0
      loader?.center = view.center
      self.view.addSubview(loader!)
    }
    UIView.animate(withDuration: 0.5, animations: {self.loader?.alpha = 1})
    
    let config : URLSessionConfiguration  = {
      let configuration = URLSessionConfiguration.default
      configuration.requestCachePolicy = .returnCacheDataElseLoad
      return configuration
    }()
    
    sessionManager = Alamofire.SessionManager(configuration: config)
    
    let searchURL  = URL(string: "https://data.police.uk/api/\(force)/\(neighbourhood)/boundary")
    sessionManager?.request(searchURL!).responseJSON { response in
      
      if let status = response.response?.statusCode {
        switch(status){
        case 200:
          print("getting neighbourhoos boundary example success ooo")
        default:
          print("error getting boundary data")
        }
      }
      if let result = response.result.value {
        let jsonArray = result as! [NSDictionary]
        var coordResults: [NCoords]  = []
        for result in jsonArray {
          if let r = NCoords(json: result as! JSON){
            coordResults.append(r)
          }
        }
        DispatchQueue.main.async {
          // kill loader
          self.loader?.activityIndicator.stopAnimating()
          self.loader?.removeFromSuperview()
          self.loader = nil
         // map coordResult to CLLocatoinCoordinateArray
          
          let coordResAsCLCoords: [CLLocationCoordinate2D] = coordResults.map{CLLocationCoordinate2DMake($0.latitude,$0.longitude)}
         
          // lets try and get the map region for this neighbourhood
          
          var r : MKMapRect = MKMapRectNull
          for coord in coordResAsCLCoords {
            let p: MKMapPoint = MKMapPointForCoordinate(coord)
            r = MKMapRectUnion(r, MKMapRectMake(p.x, p.y, 0, 0))
          }
          // draw polygon on map
          
          let polygon = MKPolygon(coordinates: coordResAsCLCoords, count: coordResAsCLCoords.count)
          self.mapView?.add(polygon)
          
          
          let region = MKCoordinateRegionForMapRect(r)
          self.mapView.setRegion(region, animated: true)
          
          

         self.fbpins = []
          
          self.search.performSearch(coords: coordResAsCLCoords ) {success in
            self.generateFBAnnotations(results: success.0)
 
          }
          
          
        }
      }
    }
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
        (clusterView as! FBAnnotationClusterView).reset()
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
        if let ind = i {
          rightButton.tag = ind
        }
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
        let resultToDisplay = annotation as! SearchResult
        pinView?.annotation = annotation
        pinView?.pinTintColor = resultToDisplay.color
        let i = fbpins.index(of: resultToDisplay)
        if let ind = i {
          pinView?.rightCalloutAccessoryView?.tag = ind
        }
      }
      return pinView
    }
  }
  
  func showDetails(_ sender: UIButton) {
    performSegue(withIdentifier: "showDetail", sender: sender.tag)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    search.cancelSearches()
    
    if segue.identifier == "showGraphs" {
      
      let controller = segue.destination as! GraphsTabBarController
      controller.data  = fbpins
    }
    
    if segue.identifier == "showDetail" {
      let controller = segue.destination as! DetailViewController
      controller.data = fbpins[sender as! Int]
    }
    if segue.identifier == "setDate" {
      let controller  = segue.destination as! DateController
      slideInTransitioningDelegate.direction = .bottom
      slideInTransitioningDelegate.disableCompactHeight = true
      controller.transitioningDelegate = slideInTransitioningDelegate
      controller.modalPresentationStyle = .custom
    }
    if segue.identifier == "showClusterInfo" {
      let controller = segue.destination as! ClusterInfoTableViewController
      controller.cluster  = sender as? FBAnnotationCluster
    
    }
    
    if segue.identifier == "settings" {
      print ("loading settings")
    }
    
    if segue.identifier == "loadControls" {
      let tabController = segue.destination as! UITabBarController
      if let catController = tabController.viewControllers?[0] as? ControlsTableViewController{
      catController.checked = sender as! [Bool]?
     // catController.enabledSections = self.enabledSections
  //   catController.delegate = self
      }
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
    if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy  || located {
      located = true
      print ("improving")
      lastLocationError = nil
      location = newLocation
      if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
        search.cancelSearches()
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

extension MapViewController: FBAnnotationClusterViewDelegate {
  func touchBegan() {
    search.cancelSearches()
  }
  
  func showClusterInfo(for cluster: FBAnnotationCluster) {
    performSegue(withIdentifier: "showClusterInfo", sender: cluster)
  }
}

extension MapViewController: SearchDelegate {
  func searchStarted() {
    let nav = navigationController as! ExtendedNavController
    if let _ = nav.visibleViewController as? MapViewController {
      nav.setStatusMessage(message: "loading...")
    }
    if (loader == nil) {
      loader = Loader(message: "loading crime data...")
      loader?.alpha = 0
      loader?.center = view.center
      self.view.addSubview(loader!)
    }
    UIView.animate(withDuration: 0.5, animations: {self.loader?.alpha = 1})
   
  }
  
  func searchComplete(tooMany: Int, unknown: Int) {
    UIView.animate(withDuration: 0.5, animations: {self.loader?.alpha = 0}, completion: { finished in
      self.loader?.removeFromSuperview()
      self.loader = nil
      let nav = self.navigationController as! ExtendedNavController
      if let _ = nav.visibleViewController as? MapViewController {
        nav.setStatusMessage(message: "touch pin or cluster for info")
      }
      if tooMany > 0 {
        let alert = UIAlertController(title: "Too many results", message: "Some categories returned too many results, try narrowing search area.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        alert.view.tintColor = UIColor.flatMint
        self.present(alert, animated: true, completion: nil)
        
      } else if unknown > 0 {
        let alert = UIAlertController(title: "Error", message: "There were errors retreiving data for some categories.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        alert.view.tintColor = UIColor.flatMint
        self.present(alert, animated: true, completion: nil)
      }
    })
  }
}


extension MapViewController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    
    
    let nav = navigationController as! ExtendedNavController
    
    if let controller = viewController as? InitialisesExtendedNavBar {
      nav.setExtendedBarColor(controller.extendedNavBarColor)
      nav.setStatusMessage(message: controller.extendedNavBarMessage, size: controller.extendedNavBarFontSize, color: controller.extendedNavBarFontColor )
      nav.showDate(controller.extendedNavBarShouldShowDate)
      nav.shouldHideExtendedBar(controller.extendedNavBarIsHidden)
    }
  }
}


  





