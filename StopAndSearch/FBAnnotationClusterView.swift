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

    }
  
  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print ("began")
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

	private func updateClusterSize() {
		if let cluster = annotation as? FBAnnotationCluster {

			let count = cluster.annotations.count
			let template = configuration.templateForCount(count: count)

			switch template.displayMode {
			case .Image(let imageName):
				image = UIImage(named: imageName)
				break
			case .SolidColor(let sideLength, let color):
				backgroundColor	= color
				frame = CGRect(origin: frame.origin, size: CGSize(width: sideLength, height: sideLength))
				break
			}

			layer.borderWidth = template.borderWidth
			countLabel.font = template.font
			countLabel.text = "\(count)"

			setNeedsLayout()
		}
	}

    override public func layoutSubviews() {
		super.layoutSubviews()
		countLabel.frame = bounds
		layer.cornerRadius = image == nil ? bounds.size.width / 2 : 0
    }
}
