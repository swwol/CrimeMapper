

import UIKit

enum PresentationDirection {
  case left
  case top
  case right
  case bottom
}

class SlideInPresentationManager: NSObject {
  var direction = PresentationDirection.left
  var disableCompactHeight = false
}


extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {

  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,source:UIViewController) -> UIPresentationController? {
    let presentationController = SlideInPresentationController(presentedViewController: presented,
                                                               presenting: presenting,
                                                               direction: direction)
    presentationController.delegate = self
    return presentationController
  }
  
  func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return SlideInPresentationAnimator(direction: direction, isPresentation: true)
  }
  
  func animationController(forDismissed dismissed: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
      return SlideInPresentationAnimator(direction: direction, isPresentation: false)
  }

}

// MARK: - UIAdaptivePresentationControllerDelegate
extension SlideInPresentationManager: UIAdaptivePresentationControllerDelegate {
  
  
  func adaptivePresentationStyle(for controller: UIPresentationController,
                                 traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    if traitCollection.verticalSizeClass == .compact && disableCompactHeight {
      return .overFullScreen
    } else {
      return .none
    }
  }
}
