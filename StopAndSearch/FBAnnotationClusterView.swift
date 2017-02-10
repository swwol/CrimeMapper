//
//  FBAnnotationClusterView.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import MapKit

protocol FBAnnotationClusterViewDelegate {
  
  func showClusterInfo(for cluster: FBAnnotationCluster)
  func touchBegan()
}

public class FBAnnotationClusterView : MKAnnotationView {
  
  var delegate: FBAnnotationClusterViewDelegate?

	private var configuration: FBAnnotationClusterViewConfiguration

	private let countLabel: UILabel = {
		let label = UILabel()
		label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		label.textAlignment = .center
		label.backgroundColor = UIColor.clear
		label.textColor = UIColor.white
    //label.shadowColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)

    //label.shadowOffset = CGSize(width: 2, height: 5)

		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 2
		label.numberOfLines = 1
		label.baselineAdjustment = .alignCenters
		return label
	}()

	public override var annotation: MKAnnotation? {
		didSet {
			updateClusterSize()
		}
	}
  
  func applyPlainShadow(view: UIView) {
    let l = view.layer
    
    l.shadowColor = UIColor.black.cgColor
    l.shadowOffset = CGSize(width: 2, height: 2)
    l.shadowOpacity = 0.4
    l.shadowRadius = 3
  }
  
    public convenience init(annotation: MKAnnotation?, reuseIdentifier: String?, configuration: FBAnnotationClusterViewConfiguration){
        self.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		self.configuration = configuration
		self.setupView()
    }

	public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		self.configuration = FBAnnotationClusterViewConfiguration.default()
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		self.setupView()
	}

    required public init?(coder aDecoder: NSCoder) {
		self.configuration = FBAnnotationClusterViewConfiguration.default()
        super.init(coder: aDecoder)
		self.setupView()
    }
    
    private func setupView() {
		backgroundColor = UIColor.clear
		layer.borderColor = UIColor.white.cgColor
		addSubview(countLabel)
    applyPlainShadow(view: countLabel)
    applyPlainShadow(view: self)
    }
  
  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print ("began!!!!!!!!!!!!!!!!!!!!!!")
    delegate?.touchBegan()
    self.alpha = 0.5
    self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
  }
  
  override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("ended")
    self.alpha = 1
    self.transform = CGAffineTransform.identity
    if let cluster  = self.annotation  as? FBAnnotationCluster {
    delegate?.showClusterInfo(for: cluster)
    }
  }
  
  public func reset() {
    
    if self.alpha != 1 {
      
      print ("NEEDS RESET")
      self.alpha = 1
      self.transform = CGAffineTransform.identity
      
      
    }
    
    
  }

	private func updateClusterSize() {
		if let cluster = annotation as? FBAnnotationCluster {

			let count = cluster.annotations.count
			let template = configuration.templateForCount(count: count)

			switch template.displayMode {
			case .Image(let imageName):
				image = UIImage(named: imageName)
				break
			case .SolidColor(let sideLength, _ ):
			
        var slices = [(value:CGFloat, color:UIColor)]()
        
        for (i,cat) in Categories.categories.enumerated() {
          
          
          //how many annotations in cluster.annotations have title of category?
          
          let justThisCat = cluster.annotations.filter { $0.title! == cat.category }
          
          slices.append( (value: CGFloat(justThisCat.count), color: Categories.categories[i].color)   )
          
          
        }
        
        // get number of slices for each category
        
        
        
     
        
        let size  = CGSize(width: sideLength, height: sideLength)
				self.frame = CGRect(origin: frame.origin, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        drawPieChart(slices: slices, at:CGPoint(x:sideLength/2,y:sideLength/2), radius:sideLength/2 )
        self.layer.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
				break
			}

			layer.borderWidth = template.borderWidth/2
			countLabel.font = template.font
			countLabel.text = "\(count)"

			setNeedsLayout()
		}
	}
  
  
  
  func drawPieChart(slices:[(value:CGFloat, color:UIColor)], at center:CGPoint, radius:CGFloat)
  {
    // the calue component of the tuples are summed up to get the denominator for surface ratios
    let totalValues:CGFloat = slices.reduce(0, {$0 + $1.value})
    
    // starting at noon (-90deg)
    var angle:CGFloat = -CGFloat(M_PI)/2
    
    // draw each slice going counter clockwise
    for (value,color) in slices
    {
      let path = UIBezierPath()
      
      // slice's angle is proportional to circumference 2π
      let sliceAngle = CGFloat(M_PI)*2*value/totalValues
      // select fill color from tuple
      color.setFill()
      
      // draw pie slice using arc from center and closing path back to center
      path.move(to: center)
      path.addArc( withCenter: center,
                             radius: radius,
                             startAngle: angle,
                             endAngle: angle - sliceAngle,
                             clockwise: false
      )
      path.move(to: center)
      path.close()
      
      // draw slice in current context
      path.fill()
      
      // offset angle for next slice
      angle -= sliceAngle
    }
  }


    override public func layoutSubviews() {
		super.layoutSubviews()
		countLabel.frame = bounds
		layer.cornerRadius = image == nil ? bounds.size.width / 2 : 0
    }
}
