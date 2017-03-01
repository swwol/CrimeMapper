
import UIKit

class ExtendedNavController: UINavigationController {
  
  let topView = OverlayBar.instanceFromNib() as! OverlayBar
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    topView.startDate.textColor = .flatGrayDark
    topView.endDate.textColor = .flatGrayDark
    topView.areaID.textColor = .flatGrayDark
    topView.area.textColor = .flatGrayDark
    setTopViewFrame()
    self.view.addSubview(topView)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func setExtendedBarColor(_ color: UIColor) {
    topView.bgview.backgroundColor = color
  }
  
  func shouldHideExtendedBar( _ b: Bool ) {
    topView.isHidden = b
  }
  
  
  func setTopViewFrame() {
    let nbh  = self.navigationBar.frame.size.height
    let nby  = self.navigationBar.frame.origin.y
    topView.frame = CGRect ( x: 0 , y: nbh + nby, width: self.view.frame.size.width, height: 60)
    
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    setTopViewFrame()
  }
  
  
  func updateInfo(){
    let defaults = UserDefaults.standard
    let  startMonth  = defaults.integer(forKey: "startMonth")
    let  startYear  = defaults.integer(forKey: "startYear")
    let  endMonth  = defaults.integer(forKey: "endMonth")
    let  endYear  = defaults.integer(forKey: "endYear")
    var startDate: MonthYear? = nil
    var endDate: MonthYear?  = nil
    if( startMonth != 0 && startYear != 0){
      startDate  = MonthYear(month: startMonth, year: startYear)
    }
    if( endMonth != 0 && endYear != 0){
      endDate  = MonthYear(month: endMonth, year: endYear)
    }
    
    if let sd = startDate {
      if let ed = endDate {
        if sd != ed {
          topView.startDate.text = "\(sd.getDateAsString()) - "
          topView.endDate.text = ed.getDateAsString()
        } else {
          topView.startDate.text = ""
          topView.endDate.text = sd.getDateAsString()
        }
      } else {
        //end date is nil, just show start date
        topView.startDate.text = ""
        topView.endDate.text = sd.getDateAsString()
      }
    }
    
    if let n = defaults.object(forKey: "neighbourhood") {
      if let nUnwrapped = n as? String {
        topView.areaID.text = "area Id:"
        topView.area.text = nUnwrapped
      } else {
           topView.areaID.text = ""
           topView.area.text = "visible region"
      }
    }
  }
  
  func showDate(_ show: Bool) {
    if show {
    topView.startDate.isHidden = false
    topView.endDate.isHidden = false
    } else {
      topView.startDate.isHidden = true
      topView.endDate.isHidden = true
    }
  }
  func setStatusMessage(message: String, size: CGFloat = 12, color: UIColor = .flatBlack) {
    topView.sLabel.textColor = color
    topView.sLabel.font = topView.sLabel.font.withSize(size)
    topView.sLabel.text = message
  }
  
  
}
