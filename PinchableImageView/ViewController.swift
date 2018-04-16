//
//  ViewController.swift
//  PinchableImageView
//
//  Created by Jinsei Shima on 2018/04/16.
//  Copyright © 2018 Jinsei Shima. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var dimView = UIView()
    var imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor.black
        dimView.alpha = 0
        view.addSubview(dimView)

        let imageView = UIImageView(image: UIImage(named: "sample1"))
        imageView.isUserInteractionEnabled = true
        imageView.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
        imageView.center = view.center
        view.addSubview(imageView)

        let overlayView = PinchDetector(frame: imageView.frame)
        overlayView.delegate = self
        view.addSubview(overlayView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: PinchDetectorDelegate {

    func pinchScale(value: CGFloat) {
        print(value)
        let scale = (value - 1) / 5
        let alpha = scale > 0.6 ? 0.6 : scale
        dimView.alpha = alpha
    }

    func targetView() -> UIView {
        return imageView
    }
}
