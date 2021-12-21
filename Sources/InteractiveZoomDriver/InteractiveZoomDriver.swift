import UIKit

public class InteractiveZoomDriver<T: UIView> : NSObject, UIGestureRecognizerDelegate {
  
  let sourceView: T
  
  public private(set) var isZooming = false
  
  private var frontWindow: UIWindow?
  
  private let targetViewFactory: (T) throws -> UIView
  
  private let shouldZoomTransform: (T) throws -> Bool
  
  private var currentInteractingView: UIView?
  
  private lazy var pinchGesture = UIPinchGestureRecognizer(
    target: self,
    action: #selector(self.pinch(sender:))
  )
  
  private lazy var panGesture = UIPanGestureRecognizer(
    target: self,
    action: #selector(self.pan(sender:))
  )
  
  public init(
    gestureTargetView: UIView,
    sourceView: T,
    targetViewFactory: @escaping (T) throws -> UIView,
    shouldZoomTransform: @escaping (T) throws -> Bool
  ) {
    
    self.sourceView = sourceView
    self.targetViewFactory = targetViewFactory
    self.shouldZoomTransform = shouldZoomTransform

    super.init()
    
    pinchGesture.delegate = self
    panGesture.delegate = self

    gestureTargetView.addGestureRecognizer(pinchGesture)
    gestureTargetView.addGestureRecognizer(panGesture)
  }
  
  deinit {
    #if DEBUG
    print("deinit: InteractiveZoomDriver")
    #endif
  }
  
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc private func pinch(sender: UIPinchGestureRecognizer) {
    
    do {
      let isZoom = try shouldZoomTransform(sourceView)
      guard isZoom else { return }
    } catch {
      fatalError(error.localizedDescription)
    }
    
    switch sender.state {
    case .began:
      
      do {
        currentInteractingView = try targetViewFactory(sourceView)
      } catch {
        fatalError(error.localizedDescription)
      }

      guard let targetView = currentInteractingView else {
        return
      }
      
      if frontWindow == nil {
        frontWindow = UIWindow(frame: UIScreen.main.bounds)
      }
      
      targetView.transform = .identity
      targetView.frame = sourceView.convert(sourceView.bounds, to: frontWindow)
      targetView.isUserInteractionEnabled = true
      frontWindow?.addSubview(targetView)
      frontWindow?.isHidden = false

      // NOTE: For reduce flicker
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
        self.sourceView.isHidden = true
      }

      let currentScale = targetView.frame.size.width / targetView.bounds.size.width
      let newScale = currentScale * sender.scale
      if newScale > 1 {
        isZooming = true
      }
      
    case .changed:
      
      guard let targetView = currentInteractingView else {
        return
      }
      
      assert(targetView.transform.a == targetView.transform.d)
      
      let currentScale = targetView.transform.a
      var newScale = currentScale * sender.scale
      
      if newScale < 1 {
        newScale = 1
        let transform = CGAffineTransform(scaleX: newScale, y: newScale)
        targetView.transform = transform
      }
      else {
        
        let pinchCenter = CGPoint(
          x: sender.location(in: targetView).x - targetView.bounds.midX,
          y: sender.location(in: targetView).y - targetView.bounds.midY
        )
        
        targetView.transform = targetView
          .transform
          .translatedBy(x: pinchCenter.x, y: pinchCenter.y)
          .scaledBy(x: sender.scale, y: sender.scale)
          .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
        
      }
      sender.scale = 1
      
      updateBackgroundColor(progress: newScale)
      
    case .cancelled, .failed, .ended:
      
      guard let targetView = currentInteractingView else {
        return
      }

      UIView.animate(
        withDuration: 0.25,
        delay: 0,
        usingSpringWithDamping: 1,
        initialSpringVelocity: 0,
        options: [.beginFromCurrentState, .allowUserInteraction],
        animations: {
          targetView.transform = .identity
          targetView.frame = self.sourceView.convert(self.sourceView.bounds, to: self.frontWindow)
          self.frontWindow?.backgroundColor = .clear
      }, completion: { _ in
        self.isZooming = false
        self.sourceView.isHidden = false
        // NOTE: For reduce flicker
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
          targetView.removeFromSuperview()
          self.currentInteractingView = nil
          self.frontWindow?.isHidden = true
          self.frontWindow = nil
        }
      })
      
    default:
      break
    }
  }
  
  @objc private func pan(sender: UIPanGestureRecognizer) {
    
    if isZooming == false { return }
    
    switch sender.state {
    case .changed:
      
      guard let targetView = currentInteractingView else {
        return
      }
      
      let translation = sender.translation(in: sender.view)
      targetView.center = CGPoint(
        x: targetView.center.x + translation.x,
        y: targetView.center.y + translation.y
      )
      sender.setTranslation(CGPoint.zero, in: targetView.superview)
      
    default:
      break
      
    }
  }
  
  private func updateBackgroundColor(progress: CGFloat) {
    
    let scale = (progress - 1) / 4
    let alpha = max(0.6, scale)
    
    UIView.animate(withDuration: 0.2, animations: {
      self.frontWindow?.backgroundColor = UIColor(white: 0, alpha: alpha)
    })
  }
  
  @objc
  public func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    
    if gestureRecognizer.numberOfTouches == 1 {
      return true
    }
    if otherGestureRecognizer == pinchGesture {
      return true
    }
    return false
  }
}
