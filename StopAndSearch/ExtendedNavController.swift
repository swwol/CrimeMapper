
import UIKit

class ExtendedNavController: UINavigationController {
  
  let topView = OverlayBar.instanceFromNib() as! OverlayBar
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    topView.dateLabel.textColor = UIColor.init(complementaryFlatColorOf: .flatMintDark)
    setTopViewFrame()
    self.view.addSubview(topView)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func setExtendedBarColor(_ color: UIColor) {
    topView.bgview.backgroundColor = color
  }
  
  func setTopViewFrame() {
    let nbh  = self.navigationBar.frame.size.height
    let nby  = self.navigationBar.frame.origin.y
    topView.frame = CGRect ( x: 0 , y: nbh + nby, width: self.view.frame.size.width, height: 60)
    
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    setTopViewFrame()
  }
  
  func setDate(month: Int?, year: Int?) {
    // set date from last data available API call
    if let m = month, let y = year {
      topView.dateLabel.text = "\(Months.months[m-1])-\(y)"
    } else {
     topView.dateLabel.text = "all dates"
    }
  }
  func setDate(date:MonthYear?, isOn: Bool){
    //set date from date picker
    if let d = date, isOn {
      topView.dateLabel.text = "\(d.monthName)-\(d.yearAsString)"
    }else {
      topView.dateLabel.text = "all dates"
    }
  }

  func setStatusMessage(message: String) {
    topView.sLabel.text = message    
  }
  
  
}
