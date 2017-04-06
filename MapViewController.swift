//
//  MapViewController.swift

import Foundation
import UIKit
import MapKit
import CoreLocation
import Alamofire
import Gloss
import PromiseKit
import CoreGraphics
import RSClipperWrapper

class MapViewController: UIViewController, CLLocationManagerDelegate, InitialisesExtendedNavBar {
  
  @IBAction func graphButtonPressed(_ sender: UIBarButtonItem) {
    search.cancelSearches()
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
  var searchCompleted: Bool = false
  
  let clusteringManager  = FBClusteringManager()
  var fbpins = [SearchResult]()

  
  var monthYear: MonthYear? = nil
  var readyToSearch = false
  var loader: Loader?
  
  var force: String?
  var neighbourhood : String?
  var neighbourhoodSquare: [CLLocationCoordinate2D]?
  var renderer: MKPolygonRenderer?
  var sessionManager : SessionManager?
  lazy var slideInTransitioningDelegate = SlideInPresentationManager()
  var mapScale: Double?
  var searchedArea: [CLLocationCoordinate2D]?
  var searchCoords = [CLLocationCoordinate2D]()
  
  @IBAction func adjustSettings(_ sender: UIBarButtonItem) {
 
    search.cancelSearches()
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
    search.cancelSearches()
    getLocation()
  }
  
  func getLocation() {
      defaults.set(nil, forKey: "neighbourhood")
     neighbourhood = nil
      neighbourhoodSquare = nil
      renderer = nil
    self.updateDateExtendedNavBarInfo()    // authorise
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
  
  
  func getMKMapRectFromCoords ( ne: CLLocationCoordinate2D, sw: CLLocationCoordinate2D) -> MKMapRect {
    
    let nemp  = MKMapPointForCoordinate(ne)
    let swmp =  MKMapPointForCoordinate(sw)
    
    return MKMapRectMake(min(nemp.x, swmp.x), min(nemp.y, swmp.y), abs(nemp.x-swmp.x), abs(nemp.y-swmp.y))
    
  }
  
  
  
  func doesPolyAContainPolyB (a: [CLLocationCoordinate2D], b: [CLLocationCoordinate2D]) -> Bool {
    
    
    // just check if all points of PolygonB are inside A (should work for convex poly)
    
    let CGpolyA = convertCLPolyToCGPoints(poly: a)
    let CGpolyB = convertCLPolyToCGPoints(poly: b)
    
    
    for point in CGpolyB {
    
      if !Clipper.polygonContainsPoint(CGpolyA, point: point) {
        return false
       }
    }
    
    return true
    
  }
  
  
  func intersectionOfPolyAndRect (poly: [CLLocationCoordinate2D], rect: MKMapRect) -> [CGPoint] {
    let rectAsMapPoints  = getCoordsFromRect(rect: rect)
    let rectAsCGPoints = convertMKMapPointsToCGPoints(rectAsMapPoints)
    let polyAsCGPoints = poly.map {self.mapView.convert($0, toPointTo: self.view) }
    
    let  intersection  =  Clipper.intersectPolygons([polyAsCGPoints], withPolygons: [rectAsCGPoints])
    
    if !intersection.isEmpty {
      
      return intersection[0]
      
    } else {
      return []
    }
  }
  
  func convertCLPolyToCGPoints ( poly: [CLLocationCoordinate2D] ) -> [CGPoint] {
    return poly.map {self.mapView.convert($0, toPointTo: self.view) }
  }
  
    
  func getCoordsFromRect (rect: MKMapRect) -> [MKMapPoint] {
    let left = MKMapRectGetMinX(rect)
    let bottom = MKMapRectGetMinY(rect)
    let right = MKMapRectGetMaxX(rect)
    let top = MKMapRectGetMaxY(rect)
    let bottomLeft = MKMapPoint(x: left, y: bottom)
    let topLeft =  MKMapPoint(x: left, y: top)
    let topRight =  MKMapPoint(x: right, y: top)
    let bottomRight = MKMapPoint(x: right, y: bottom)
    let coords = [bottomLeft, topLeft, topRight, bottomRight]
    return coords
  }
  
  func convertMKMapPointsToCGPoints( _ mapPoints : [MKMapPoint]) -> [CGPoint] {
   
    let coordsAsCL2d : [CLLocationCoordinate2D] = mapPoints.map { MKCoordinateForMapPoint($0)  }
    return coordsAsCL2d.map {self.mapView.convert($0, toPointTo: self.view)}

  }
  
  func getPolygonOfRectXMinusPoly( fullRect: MKMapRect, excludeArea: [CLLocationCoordinate2D]) -> [[CGPoint]] {
    
  // get both rect coords as  CGPoints
    
    let fullRectCoords = convertMKMapPointsToCGPoints(getCoordsFromRect(rect: fullRect))
    let excludeAreaCoords = convertCLPolyToCGPoints(poly: excludeArea)
    
    //get polygon of difference
  
    let searchPoly = Clipper.differencePolygons([fullRectCoords], fromPolygons: [excludeAreaCoords])
    return searchPoly
    
  }
  
  
  func convertCGPointsPolyToCL2D(_ poly: [CGPoint]) -> [CLLocationCoordinate2D] {
    let polyAsCLL2d : [CLLocationCoordinate2D] = poly.map{self.mapView.convert($0, toCoordinateFrom: self.view)}
    return polyAsCLL2d
  
  }
  
  func getUnionOfPolyAndPoly (poly1: [CLLocationCoordinate2D], poly2: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
    
    let poly1AsCGPoints  = convertCLPolyToCGPoints (poly: poly1)
    let poly2AsCGPoints  = convertCLPolyToCGPoints (poly: poly2)
    let union = Clipper.unionPolygons([poly1AsCGPoints], withPolygons: [poly2AsCGPoints])[0]
    return  convertCGPointsPolyToCL2D(union)
  }
  
  func setSearchCoords() -> Bool{
    
    let region  = mapView.region
    let centre  =  region.center
    let span = region.span
    let ne = CLLocationCoordinate2DMake(centre.latitude + span.latitudeDelta / 2.0, centre.longitude - span.longitudeDelta / 2.0)
    let sw = CLLocationCoordinate2DMake(centre.latitude - span.latitudeDelta / 2.0, centre.longitude + span.longitudeDelta / 2.0)
    let mapRectOfCurrentSearch  = getMKMapRectFromCoords(ne: ne, sw: sw)

    if let ns  = neighbourhoodSquare {
      searchCoords  = ns
      return true
    } else {

      //get new search region, but don't search all again unless categories changes
      
      if let lastSearchPoly = searchedArea {
        
        //we need currentmap rect as array of CLLocationCoordinate2d points
        
        let mapRectAsPoly =  getCoordsFromRect(rect: mapRectOfCurrentSearch)
        let mapRectAsCLLCoordinatePoly :  [CLLocationCoordinate2D] = mapRectAsPoly.map { MKCoordinateForMapPoint($0)  }
        
        // did any searchcriteria change? if so start a new search
        let updated = defaults.bool(forKey: "searchUpdated")
        if (updated) {
          print ("SEARCHCOORD:new search because cat updated")
          fbpins = []
         searchedArea = nil
          searchCoords = mapRectAsCLLCoordinatePoly
          return true
        }
        // check if last search contains mapRectofCurrentSearch
        // it will if we zoomed in
        
        if doesPolyAContainPolyB ( a: lastSearchPoly, b: mapRectAsCLLCoordinatePoly) {
          // if lastSearchPolygon contains current search rect
          print ("SEARCHCOORD:current search contained inside last search - ie zoomed in")
          
          //if search criteria didn;t change, don't do a new search, just send exisiting pins to clustering manager
          self.generateFBAnnotations(results: [])
          return false
        
          
        } else if doesPolyAContainPolyB( a: mapRectAsCLLCoordinatePoly, b: lastSearchPoly)  {
          // if we zoomed out so last search area is contained within mapRect
          // start search from scratch as poygon has a hole in the middle
          print ("SEARCHCOORD:current rect contains poly- ie zoomed out")
          fbpins = []
          searchCoords =  getCoordsFromRect(rect: mapRectOfCurrentSearch).map { MKCoordinateForMapPoint($0)}
          return true
        } else {
          let intersection = intersectionOfPolyAndRect(poly: lastSearchPoly, rect: mapRectOfCurrentSearch)
          if !intersection.isEmpty {
            print ("SEARCHCOORD:they intersect")
            
            // if they intersect
            let searchPoly =  getPolygonOfRectXMinusPoly(fullRect: mapRectOfCurrentSearch, excludeArea: lastSearchPoly)[0]
            // convert searchpoly to CLLocations
            let searchPolyAsCL2DCoords = convertCGPointsPolyToCL2D(searchPoly)
            searchCoords = searchPolyAsCL2DCoords
            return true
          } else {
            print ("SEARCHCOORD:they dont intersect")
            // they don't intersect
            fbpins = []
            searchedArea = nil
            searchCoords =  getCoordsFromRect(rect: mapRectOfCurrentSearch).map { MKCoordinateForMapPoint($0)}
            return true
          }
        }
      } else {
        
        print ("SEARCHCOORD:no previous search")
        // no previous search
        searchCoords =  getCoordsFromRect(rect: mapRectOfCurrentSearch).map { MKCoordinateForMapPoint($0)  }
        return true
      }
    }
  }
  
  //////////////////////////////////////////////////
  
  // find  and display datapoints within viewable region
  
  func findAndDisplayDataPointsInVisibleRegion() {
    
    
    guard readyToSearch else {
      return
    }

    // if setSearchCoords returns false, we don't carry on search as this area has been searched already
    guard setSearchCoords() else {
    return
    }
    
    
  search.performSearch(coords: searchCoords ) { results in
    
    if let _ = self.neighbourhoodSquare, let ren = self.renderer {
    //renderer not nil if neighbourhood is set
    //cull any results that are not within my polygon
    let resultsWithinPolygon = results.filter {
      let currentMapPoint =  MKMapPointForCoordinate($0.coordinate)
      let polygonViewPoint: CGPoint  = ren.point(for: currentMapPoint)
      if  (ren.path).contains(polygonViewPoint) {
        return true
      }
      return false  }
      self.searchedArea = nil
      self.generateFBAnnotations(results: resultsWithinPolygon)
    } else {
      
      print ("I'm here because renderer is nil")

      if let wasSearched  = self.searchedArea {
        self.searchedArea = self.getUnionOfPolyAndPoly(poly1: wasSearched, poly2: self.searchCoords)
      } else {
        self.searchedArea = self.searchCoords
      }
        self.generateFBAnnotations(results: results)
    }
    //  self.searchComplete()
    }
  }
  
  
  ///////
  func getSearchNeighbourhoodID() {
    
    if let n = defaults.object(forKey: "neighbourhood"), let f = defaults.object(forKey: "force") {
      if let nUnwrapped = n as? String, let fUnwrapped = f as? String {
        neighbourhood = nUnwrapped
        force = fUnwrapped
      } else {
        neighbourhood = nil
        force  = nil
        renderer = nil
        neighbourhoodSquare = nil
        removeOverlays()
          }
    }
  }
  
  func removeOverlays() {
    
    for overlay in self.mapView!.overlays {
      self.mapView!.remove(overlay)
    }

  }
  
  func removeAnnotations() {
    print("removing annotations")
    fbpins = []
    clusteringManager.removeAll()
    clusteringManager.display(annotations: [], onMapView: self.mapView)
  }
  
  func getScale () ->Double {
    let mapBoundsWidth = Double(self.mapView.bounds.size.width)
    let mapRectWidth = self.mapView.visibleMapRect.size.width
    let scale = mapBoundsWidth / mapRectWidth
    return scale
  }
  
  func generateFBAnnotations(results: [SearchResult]) {
    
    
    fbpins += results
    
    clusteringManager.removeAll()
    clusteringManager.add(annotations: fbpins)
    DispatchQueue.global(qos: .userInitiated).async {
    //  let mapBoundsWidth = Double(self.mapView.bounds.size.width)
    // let mapRectWidth = self.mapView.visibleMapRect.size.width
      let scale = self.getScale()
      
      print ("scale",scale)
      let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale: scale)
      print ("annotatoins array \(annotationArray)")
    
      DispatchQueue.main.async {
        self.clusteringManager.display(annotations: annotationArray, onMapView:self.mapView)
      }
    }
  }
  
  
  func  getNeighbourhoodBoundary(force: String, neighbourhood: String) -> Promise<[CLLocationCoordinate2D]> {
      self.removeOverlays()
  
    let config : URLSessionConfiguration  = {
      let configuration = URLSessionConfiguration.default
      configuration.requestCachePolicy = .returnCacheDataElseLoad
      return configuration
    }()
    
    sessionManager = Alamofire.SessionManager(configuration: config)
    let searchURLString  =  "https://data.police.uk/api/\(force)/\(neighbourhood)/boundary"
    
    let searchURLStringEncoded = searchURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let searchURL  = URL (string: searchURLStringEncoded!)
    return Promise { fulfill, reject in
      if (self.loader == nil) {
        self.loader = Loader(message: "loading region...", size: "small")
        self.loader?.center = view.center
        self.view.addSubview(self.loader!)
      }
      
    sessionManager!.request(searchURL!)
      .validate()
      .responseJSON() { response in
        switch response.result {
        case .success(let dict):
          guard let dictArray  = dict as? [NSDictionary] else {
            return
          }
          var coordResults: [NCoords]  = []
          for result in dictArray {
            if let r = NCoords(json: result as! JSON){
              coordResults.append(r)
            }
          }
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
          
          let lowerLeft = MKCoordinateForMapPoint(MKMapPoint(x: r.origin.x, y: r.origin.y))
          let lowerRight =  MKCoordinateForMapPoint(MKMapPoint(x: r.origin.x + r.size.width, y: r.origin.y))
          let topLeft =  MKCoordinateForMapPoint(MKMapPoint(x: r.origin.x, y: r.origin.y + r.size.height))
          let topRight = MKCoordinateForMapPoint(MKMapPoint(x: r.origin.x + r.size.width, y: r.origin.y + r.size.height))
          self.neighbourhoodSquare  = [lowerLeft,lowerRight,topRight,topLeft]
          let region = MKCoordinateRegionForMapRect(r)
          self.mapView.setRegion(region, animated: false)
          self.loader?.removeFromSuperview()
          self.loader = nil
          fulfill(coordResAsCLCoords)
        case .failure (let err):
          self.loader?.removeFromSuperview()
          self.loader = nil
          reject(err)
        }
      }
    }
  }
  
  func getDateLastUpdated( _ setStart: Bool = false) -> Promise<String> {
    
    
    return Promise { fulfill, reject in
      Alamofire.request("https://data.police.uk/api/crime-last-updated")
        .validate()
        .responseJSON() { response in
          switch response.result {
          case .success(let dict):
            guard let dictionary  = dict as? [String:Any], let date = dictionary["date"] as? String else {
              return
            }
            let formattedDate = MonthYear(date: date)
            self.defaults.set(formattedDate.month, forKey: "monthLastUpdated")
            self.defaults.set(formattedDate.year, forKey: "yearLastUpdated")
            if (setStart) {
              self.defaults.set(formattedDate.month, forKey: "startMonth")
              self.defaults.set(formattedDate.year, forKey: "startYear")
            }
            self.updateDateExtendedNavBarInfo()
            fulfill(date)
          case .failure(let err):
            reject(err)
          }
      }
    }
  }
  
  ///////////////
  
  func updateDateExtendedNavBarInfo() {
    let nav = self.navigationController as! ExtendedNavController
    nav.updateInfo()
  }
  
  @IBOutlet weak var mapView: MKMapView!
 
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.delegate = self
    search.delegate = self
   
  
    
    if defaults.object(forKey: "startMonth")  == nil {
    let _ =  getDateLastUpdated(true).then { _ -> Void in
       self.updateDateExtendedNavBarInfo()
      }
    }

    //appearance
    let barTintColor = UIColor.flatMintDark
    toolbar.barTintColor=barTintColor
    //gesture recogniser to hide clusters/pins when zooming
    let zoom  = UIPinchGestureRecognizer ( target: self, action:  #selector(self.handleZoom(_:)))
    zoom.delegate = self
    mapView.addGestureRecognizer(zoom)
    mapView.isUserInteractionEnabled = true
   
    startUp()
    
    if neighbourhood == nil {
      //load users location on first load if no neighbourhood set, but not when going back to mapmevery time
      getLocation()
    }
 
  }
  
  func startUp() {
    //initiation routine
    // set values of neighbour and force from userDefaults
    getSearchNeighbourhoodID()
    if let n = neighbourhood, let f = force {
      let getDate =  getDateLastUpdated()
      let getNeighbourhood =  getNeighbourhoodBoundary(force: f, neighbourhood: n)
      when (fulfilled: getDate, getNeighbourhood).then {
        date, coords -> Void in
        self.readyToSearch = true
        self.findAndDisplayDataPointsInVisibleRegion()
        }.catch  { error in
          print ("error", error )
      }
    } else {
      getDateLastUpdated().then {
        theDate ->Void in
        self.readyToSearch = true
        self.getLocation()
        }.catch {
          error in
          print (error)
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    updateDateExtendedNavBarInfo()
    // check if cats, dates or neighbourhood changed, only do new search if they have
    let updated = defaults.bool(forKey: "searchUpdated")
    print (updated)
    if (updated) {
      getSearchNeighbourhoodID()
      if let n = neighbourhood, let f = force {
        let _ =   getNeighbourhoodBoundary(force: f, neighbourhood: n).then {_ in
          self.findAndDisplayDataPointsInVisibleRegion()
        }
        
      } else {
        findAndDisplayDataPointsInVisibleRegion()
      }
    }
  }
  
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
   
    if overlay is MKPolygon {
      renderer = MKPolygonRenderer(overlay: overlay)
      renderer?.strokeColor = .flatOrange
      renderer?.lineWidth = 2
      return renderer!
    }
    
    return MKOverlayRenderer()
  }
 

  func handleZoom( _ sender: UIPinchGestureRecognizer) {
    
      if (sender.state == UIGestureRecognizerState.began) {
        mapScale  = getScale()
        }
    
    if (sender.state == UIGestureRecognizerState.ended) {
   
        if let startScale = mapScale {
          if getScale() < startScale {
            //zoomed out
            if neighbourhood == nil {
            findAndDisplayDataPointsInVisibleRegion()
            }
          }
          mapScale = nil
      }
    generateFBAnnotations(results: [])
      
    }
  }
}

extension MapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if neighbourhood == nil {
      if let startScale = self.mapScale {
        if getScale() < startScale {
          //zoomed out
          findAndDisplayDataPointsInVisibleRegion()
        }
      } else {
        // didn't zoom so search
        findAndDisplayDataPointsInVisibleRegion()
      }
    }
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
      
      let controller = segue.destination as! GraphParentViewController
      controller.data  = fbpins
      controller.neighbourhood = self.neighbourhood
      
    }
    
    if segue.identifier == "showDetail" {
      let controller = segue.destination as! DetailViewController
      controller.data = fbpins[sender as! Int]
    }
    if segue.identifier == "setDate" {
      if let controller  = segue.destination as? DateController {
        controller.mode = sender as! String?
      }
      }
    if segue.identifier == "showClusterInfo" {
      let controller = segue.destination as! ClusterInfoTableViewController
      controller.cluster  = sender as? FBAnnotationCluster
    
    }
    
    if segue.identifier == "settings" {
      print ("loading settings")
      let controller  = segue.destination as! SettingsTableViewController
      slideInTransitioningDelegate.direction = .left
    //  slideInTransitioningDelegate.disableCompactHeight = true
      controller.transitioningDelegate = slideInTransitioningDelegate
      controller.modalPresentationStyle = .custom
      controller.delegate = self
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
      ////
      self.defaults.set(nil, forKey: "neighbourhood")
      self.neighbourhoodSquare = nil
      self.renderer = nil
      self.updateDateExtendedNavBarInfo()
      self.mapView.setRegion(localSearchResponse!.boundingRegion, animated: true)
    }
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

extension MapViewController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    let nav = navigationController as! ExtendedNavController
    if let controller = viewController as? InitialisesExtendedNavBar {
      nav.setExtendedBarColor(controller.extendedNavBarColor)
      nav.setStatusMessage(message: controller.extendedNavBarMessage, size: controller.extendedNavBarFontSize, color: controller.extendedNavBarFontColor )
      nav.showDate(controller.extendedNavBarShouldShowDate)
      nav.shouldHideExtendedBar(controller.extendedNavBarIsHidden)
    }
    
    if let _ = viewController as? MapViewController {
      nav.updateInfo()    }
  }
}

extension MapViewController: SettingsTableViewControllerDelegate {
  
  func goTo(_ destination: String) {
    
    switch (destination) {
    case "startDate":
        self.performSegue(withIdentifier: "setDate" , sender: "start")
      case "endDate":
        self.performSegue(withIdentifier: "setDate" , sender: "end")
    default:
    self.performSegue(withIdentifier: destination, sender: nil)
    }
  }
}

extension MapViewController: SearchDelegate {
 
  
  func searchStarted() {
    
    searchCompleted = false
    let nav = navigationController as! ExtendedNavController
    if let _ = nav.visibleViewController as? MapViewController {
      nav.setStatusMessage(message: "loading...")
    }
    if (loader == nil) {
      loader = Loader(message: "loading crime data...")
      loader?.center = view.center
      self.view.addSubview(loader!)
    }
  }
  
  func searchCompleted(_ success: Bool) {
    if (!success) {
      showSomeFailedAlert()
    } else {
      searchCompleted = true
      defaults.set(false,forKey:"searchUpdated")
      self.loader?.removeFromSuperview()
      self.loader = nil
      let nav = self.navigationController as! ExtendedNavController
      if let _ = nav.visibleViewController as? MapViewController {
        nav.setStatusMessage(message: "touch pin or cluster for info")
      }
    }
  }
  
  func showSomeFailedAlert() {
    let alert = UIAlertController(title: "Data failed for some categories",message:"Try using a smaller search area.", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    present(alert, animated: true, completion: {self.clearStatusMessage()})
  }

  func clearStatusMessage() {
    if let nav = navigationController as? ExtendedNavController {
        nav.setStatusMessage(message: "")
    }
  }
  
  func searchStatus(cat: String, success: Bool){
        if (success) {
            self.loader?.messageLabel.text = "\(cat) loaded"
       // nav.setStatusMessage(message: "\(cat) loaded", color: .black)
      } else  {
        
          self.loader?.messageLabel.text = "\(cat) failed"
    }
  }
}


  





