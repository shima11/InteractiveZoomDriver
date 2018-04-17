//
//  PinchableImageView.swift
//  PinchableImageView
//
//  Created by Jinsei Shima on 2018/04/16.
//  Copyright © 2018 Jinsei Shima. All rights reserved.
//

import UIKit

public class PinchGestureDriver<T: UIView> : NSObject, UIGestureRecognizerDelegate {

    let sourceView: T

    var isZooming = false
    let frontWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)

    let targetViewFactory: (T) throws -> UIView

    var currentIntereactingView: UIView?

    public init(
        gestureTargetView: UIView,
        sourceView: T,
        targetViewFactory: @escaping (T) throws -> UIView
        ) {

        self.targetViewFactory = targetViewFactory
        self.sourceView = sourceView

        super.init()

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
        pinchGesture.delegate = self
        gestureTargetView.addGestureRecognizer(pinchGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
        panGesture.delegate = self
        gestureTargetView.addGestureRecognizer(panGesture)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func pinch(sender: UIPinchGestureRecognizer) {

        switch sender.state {
        case .began:

            _ = Measure.run(name: "began", threshold: 0.003) {

                do {

                    currentIntereactingView = try targetViewFactory(sourceView)

                } catch {

                    print(error)
                }

                guard let targetView = currentIntereactingView else {
                    return
                }

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
            }


        case .changed:

            guard let targetView = currentIntereactingView else {
                return
            }

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

    // Memo: 複数のジェスチャを許可するDelegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class PinchDetectorView<T: UIView>: UIView, UIGestureRecognizerDelegate {

    var isZooming: Bool {
        return driver.isZooming
    }

    private var driver: PinchGestureDriver<T>!

    init(
        sourceView: T,
        targetViewFactory: @escaping (T) throws -> UIView
        ) {

        super.init(frame: .zero)

        self.driver = PinchGestureDriver(
            gestureTargetView: self,
            sourceView: sourceView,
            targetViewFactory: targetViewFactory
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension PinchDetectorView {

    static func clone(from fromImageView: UIImageView) -> UIImageView {
        let view = UIImageView()
        view.image = fromImageView.image
        view.clipsToBounds = fromImageView.clipsToBounds
        view.contentMode = fromImageView.contentMode
        return view
    }
}

extension PinchDetectorView where T : UIImageView {

    convenience init(
        sourceView: T
        ) {
        self.init(sourceView: sourceView, targetViewFactory: PinchDetectorView.clone)
    }
}
