//
//  ViewController.swift
//  PinchableImageView
//
//  Created by Jinsei Shima on 2018/04/16.
//  Copyright © 2018 Jinsei Shima. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var containerView: UIView!

    private lazy var overlayView1 = PinchDetectorView(
        sourceView: self.imageView1
    )

    private lazy var driver = PinchGestureDriver(gestureTargetView: imageView2, sourceView: imageView2, targetViewFactory: PinchDetectorView.clone)

    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.addSubview(overlayView1)
//        containerView.addSubview(overlayView2)

        imageView2.isUserInteractionEnabled = true

        _ = driver

    }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    overlayView1.frame = imageView1.frame

  }
}
