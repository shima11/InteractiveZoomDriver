//
//  PinchableImageView.swift
//  PinchableImageView
//
//  Created by Jinsei Shima on 2018/04/16.
//  Copyright © 2018 Jinsei Shima. All rights reserved.
//

import UIKit


protocol PinchDetectorDelegate : class {

    func pinchScale(value: CGFloat)
}

class PinchDetectorView: UIView, UIGestureRecognizerDelegate {

    weak var delegate: PinchDetectorDelegate?

    let sourceView: UIView

    var isZooming = false
    let frontWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)

    let targetViewFactory: () throws -> UIView

    var currentIntereactingView: UIView?

    init(
        sourceView: UIView,
        targetViewFactory: @escaping () throws -> UIView
        ) {

        self.targetViewFactory = targetViewFactory
        self.sourceView = sourceView

        super.init(frame: .zero)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func pinch(sender: UIPinchGestureRecognizer) {

        switch sender.state {
        case .began:

            _ = Measure.run(name: "began", threshold: 0.003) {

                do {

                    currentIntereactingView = try targetViewFactory()

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

            delegate?.pinchScale(value: newScale)
            updateBackgroundColor(progress: newScale)

        case .cancelled, .failed, .ended:

            guard let targetView = currentIntereactingView else {
                return
            }

            UIView.animate(withDuration: 0.2, animations: {
                targetView.frame = self.sourceView.convert(self.sourceView.bounds, to: self.frontWindow)
                self.frontWindow.backgroundColor = .clear
//                self.delegate?.pinchScale(value: 1.0)
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

    @objc func pan(sender: UIPanGestureRecognizer) {

        if isZooming == false { return }

        switch sender.state {
        case .changed:

            guard let targetView = currentIntereactingView else {
                return
            }

            let translation = sender.translation(in: self)
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
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
