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
    func targetView() -> UIView
}

class PinchDetector: UIView {

    var delegate: PinchDetectorDelegate!

    override init(frame: CGRect) {
        super.init(frame: frame)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchAction(sender:)))
        addGestureRecognizer(pinchGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func pinchAction(sender: UIPinchGestureRecognizer) {

        delegate.pinchScale(value: sender.scale)

        switch sender.state {
        case .began:
            print("began")
        case .changed:
            print("changed")
        case .cancelled, .failed, .ended:
            print("end")
            delegate.pinchScale(value: 1.0)
        default:
            break
        }
    }
}



//class PinchableImageView: UIView {
//
//    let imageView: UIImageView
//    let pinchGesture: UIPinchGestureRecognizer
//
//    init(frame: CGRect) {
//
//        super.init(frame: frame)
//
//
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(sender:)))
//        self.imageView.addGestureRecognizer(pinchGesture)
//        self.imageView.addGestureRecognizer(panGesture)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    @objc func pinchGesture(sender: UIPinchGestureRecognizer) {
//        print("pinch:")
//        print(sender.scale)
//    }
//
//    @objc func panGesture(sender: UIPanGestureRecognizer) {
//        print("pan:")
//        print(sender.translation(in: self))
//    }
//}

