//
//  PinchableImageView.swift
//  PinchableImageView
//
//  Created by Jinsei Shima on 2018/04/16.
//  Copyright © 2018 Jinsei Shima. All rights reserved.
//

import UIKit


protocol PinchDetectorDelegate {

    func pinchScale(value: CGFloat)
}

extension UIView {
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
}


class PinchDetector: UIView, UIGestureRecognizerDelegate {

    var delegate: PinchDetectorDelegate!

    var targetView: UIView
    let sourceView: UIView
    let originalRect: CGRect

    var isZooming = false
    var frontWindow: UIWindow = UIWindow()

    init(frame: CGRect, sourceView: UIView) {

        self.sourceView = sourceView
        self.targetView = sourceView.copyView()
        self.originalRect = sourceView.frame

        super.init(frame: frame)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)

        frontWindow = UIWindow(frame: UIScreen.main.bounds)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func pinch(sender: UIPinchGestureRecognizer) {

        switch sender.state {
        case .began:

            targetView = sourceView.copyView()
            sourceView.isHidden = true
            targetView.isUserInteractionEnabled = true
            frontWindow.addSubview(targetView)
            frontWindow.isHidden = false

            let currentScale = targetView.frame.size.width / targetView.bounds.size.width
            let newScale = currentScale * sender.scale
            if newScale > 1 {
                self.isZooming = true
            }

        case .changed:

            let currentScale = targetView.frame.size.width / targetView.bounds.size.width
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
                let transform = targetView.transform
                    .translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: sender.scale, y: sender.scale)
                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                targetView.transform = transform
            }
            sender.scale = 1

            delegate.pinchScale(value: newScale)

        case .cancelled, .failed, .ended:

            UIView.animate(withDuration: 0.2, animations: {
                self.targetView.frame = self.originalRect
                self.delegate.pinchScale(value: 1.0)
            }, completion: { _ in
                self.isZooming = false
                self.targetView.removeFromSuperview()
                self.frontWindow.isHidden = true
                self.sourceView.isHidden = false
            })

        default:
            break
        }
    }

    @objc func pan(sender: UIPanGestureRecognizer) {

        if isZooming == false { return }

        switch sender.state {
        case .began:
            break

        case .changed:
            let translation = sender.translation(in: self)
            targetView.center = CGPoint(x: targetView.center.x + translation.x, y: targetView.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: targetView.superview)

        default:
            break

        }
    }

    // Memo: 複数のジェスチャを許可するDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
