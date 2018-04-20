//
//  PinchableImageView.swift
//  PinchableImageView
//
//  Created by Jinsei Shima on 2018/04/16.
//  Copyright © 2018 Jinsei Shima. All rights reserved.
//

import UIKit

public class InteractiveZoomDriver<T: UIView> : NSObject, UIGestureRecognizerDelegate {

    let sourceView: T

    var isZooming = false
    let frontWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)

    let targetViewFactory: (T) throws -> UIView

    let shouldZoomTransform: (T) -> Bool

    var currentIntereactingView: UIView?

    private lazy var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))

    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))

    public init(
        gestureTargetView: UIView,
        sourceView: T,
        targetViewFactory: @escaping (T) throws -> UIView,
        shouldZoomTransform: @escaping (T) -> Bool
        ) {

        self.targetViewFactory = targetViewFactory
        self.sourceView = sourceView
        self.shouldZoomTransform = shouldZoomTransform

        super.init()

        pinchGesture.delegate = self
        gestureTargetView.addGestureRecognizer(pinchGesture)

        panGesture.delegate = self
        gestureTargetView.addGestureRecognizer(panGesture)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {

        pinchGesture.view?.removeGestureRecognizer(pinchGesture)
        panGesture.view?.removeGestureRecognizer(panGesture)
    }

    @objc private func pinch(sender: UIPinchGestureRecognizer) {

        if shouldZoomTransform(sourceView) == false {

            return
        }

        switch sender.state {
        case .began:

            do {

                currentIntereactingView = try targetViewFactory(sourceView)

            } catch {

                print(error)
            }

            guard let targetView = currentIntereactingView else {
                return
            }

            targetView.transform = .identity
            targetView.frame = sourceView.convert(sourceView.bounds, to: frontWindow)
            sourceView.isHidden = true
            targetView.isUserInteractionEnabled = true
            frontWindow.addSubview(targetView)
            frontWindow.isHidden = false

            let currentScale = targetView.frame.size.width / targetView.bounds.size.width
            let newScale = currentScale * sender.scale
            if newScale > 1 {
                isZooming = true
            }


        case .changed:

            guard let targetView = currentIntereactingView else {
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

                targetView.transform = targetView.transform
                    .translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: sender.scale, y: sender.scale)
                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)

            }
            sender.scale = 1

            updateBackgroundColor(progress: newScale)

        case .cancelled, .failed, .ended:

            guard let targetView = currentIntereactingView else {
                return
            }

            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.beginFromCurrentState], animations: {
                targetView.transform = .identity
                targetView.frame = self.sourceView.convert(self.sourceView.bounds, to: self.frontWindow)
                self.frontWindow.backgroundColor = .clear
            }, completion: { _ in
                self.isZooming = false
                targetView.removeFromSuperview()
                self.frontWindow.isHidden = true
                self.sourceView.isHidden = false
            })

        default:
            break
        }
    }

    @objc private func pan(sender: UIPanGestureRecognizer) {

        if isZooming == false { return }

        switch sender.state {
        case .changed:

            guard let targetView = currentIntereactingView else {
                return
            }

            let translation = sender.translation(in: sender.view)
            targetView.center = CGPoint(x: targetView.center.x + translation.x, y: targetView.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: targetView.superview)

        default:
            break

        }
    }

    private func updateBackgroundColor(progress: CGFloat) {
        let scale = (progress - 1) / 4
        let alpha = scale > 0.6 ? 0.6 : scale
        frontWindow.backgroundColor = UIColor(white: 0, alpha: alpha)
    }

    @objc
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if gestureRecognizer.numberOfTouches == 1 {
            return true
        }
        if otherGestureRecognizer == pinchGesture {
            return true
        }
        return false
    }
}

public class InteractiveZoomView<T: UIView>: UIView, UIGestureRecognizerDelegate {

    var isZooming: Bool {
        return driver.isZooming
    }

    private var driver: InteractiveZoomDriver<T>!

    public init(
        sourceView: T,
        targetViewFactory: @escaping (T) throws -> UIView,
        shouldZoomTransform: @escaping (T) -> Bool
        ) {

        super.init(frame: .zero)

        self.driver = InteractiveZoomDriver(
            gestureTargetView: self,
            sourceView: sourceView,
            targetViewFactory: targetViewFactory,
            shouldZoomTransform: shouldZoomTransform
        )
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension InteractiveZoomView {

    static func clone(from fromImageView: UIImageView) -> UIImageView {
        let view = UIImageView()
        view.image = fromImageView.image
        view.clipsToBounds = fromImageView.clipsToBounds
        view.contentMode = fromImageView.contentMode
        return view
    }

}

extension InteractiveZoomView where T : UIImageView {

    static func shouldZoomTransform(sourceView: T) -> Bool {

        if sourceView.image == nil {
            return false
        }
        return true
    }

    convenience init(
        sourceView: T
        ) {
        self.init(sourceView: sourceView, targetViewFactory: InteractiveZoomView.clone, shouldZoomTransform: InteractiveZoomView.shouldZoomTransform)
    }
}

