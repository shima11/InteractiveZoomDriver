//
//  ViewController.swift
//  Demo
//
//  Created by jinsei shima on 2018/06/17.
//

import UIKit
import InteractiveZoomDriver

class ViewController: UIViewController {

    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var containerView: UIView!

    private lazy var overlayView1 = InteractiveZoomView(
        sourceView: self.imageView1
    )

    private lazy var driver = InteractiveZoomDriver(
        gestureTargetView: imageView2,
        sourceView: imageView2,
        targetViewFactory: { (fromImageView: UIImageView) -> UIView in

            let view = UIImageView()
            view.image = fromImageView.image
            view.clipsToBounds = fromImageView.clipsToBounds
            view.contentMode = fromImageView.contentMode
            return view
    },
        shouldZoomTransform: {(sourceView: UIImageView) -> Bool in

            if sourceView.image == nil {
                return false
            }
            return true
    }
    )

    // This is also ok.
//    private lazy var driver = InteractiveZoomDriver(
//        gestureTargetView: imageView2,
//        sourceView: imageView2,
//        targetViewFactory: InteractiveZoomView.clone,
//        shouldZoomTransform: InteractiveZoomView.shouldZoomTransform
//    )

    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.layer.cornerRadius = 8.0
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        containerView.layer.shadowRadius = 16
        containerView.layer.shadowOpacity = 0.2

        containerView.addSubview(overlayView1)

        imageView2.isUserInteractionEnabled = true

        _ = driver
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        overlayView1.frame = imageView1.frame
    }
}
