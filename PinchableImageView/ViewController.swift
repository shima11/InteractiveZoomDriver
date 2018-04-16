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
    var imageView1 = UIImageView()
    var imageView2 = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView1 = UIImageView(image: UIImage(named: "sample1"))
        imageView1.contentMode = .scaleAspectFit
        imageView1.isUserInteractionEnabled = true
        imageView1.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
        imageView1.center = CGPoint(x: view.center.x, y: view.center.y - 120)
        view.addSubview(imageView1)

        imageView2 = UIImageView(image: UIImage(named: "sample2"))
        imageView2.contentMode = .scaleAspectFit
        imageView2.isUserInteractionEnabled = true
        imageView2.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
        imageView2.center = CGPoint(x: view.center.x, y: view.center.y + 120)
        view.addSubview(imageView2)

        let overlayView1 = PinchDetector(frame: imageView1.frame, sourceView: imageView1)
        overlayView1.delegate = self
        view.addSubview(overlayView1)

        let overlayView2 = PinchDetector(frame: imageView2.frame, sourceView: imageView2)
        overlayView2.delegate = self
        view.addSubview(overlayView2)

        dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor.black
        dimView.alpha = 0
        view.addSubview(dimView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: PinchDetectorDelegate {

    func pinchScale(value: CGFloat) {
        print(value)
        let scale = (value - 1) / 4
        let alpha = scale > 0.6 ? 0.6 : scale
        dimView.alpha = alpha
    }

//    func targetView() -> UIView {
//        return imageView1
//    }
}
