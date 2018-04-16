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
    ) {
        let view = UIImageView(image: UIImage(named: "sample1"))
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
      return view
    }

    private lazy var overlayView2 = PinchDetectorView(
      sourceView: self.imageView2
    ) {
        let view = UIImageView(image: UIImage(named: "sample2"))
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
      return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        overlayView1.delegate = self
        containerView.addSubview(overlayView1)

        overlayView2.delegate = self
        containerView.addSubview(overlayView2)

    }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    overlayView1.frame = imageView1.frame
    overlayView2.frame = imageView2.frame

  }
}

extension ViewController: PinchDetectorDelegate {

    func pinchScale(value: CGFloat) {

    }

}
