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
      view.layer.cornerRadius = fromImageView.layer.cornerRadius
      if #available(iOS 11.0, *) {
        view.layer.maskedCorners = fromImageView.layer.maskedCorners
      }
      return view
    },
    shouldZoomTransform: { sourceView -> Bool in
      if sourceView.image == nil {
        return false
      }
      return true
    })

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
    imageView2.layer.cornerRadius = 12
    imageView2.layer.masksToBounds = true

    _ = driver
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    overlayView1.frame = imageView1.frame
  }

}

class SecondViewController: UIViewController {

  @IBAction func didTapModalButton(_ sender: Any) {

    let controller = ModalViewController()
    present(controller, animated: true, completion: nil)
  }
}

class ModalViewController: UIViewController {

  private class TargetView: UIView {
    deinit {
      print("deinit: TargetView")
    }
  }

  private let targetView = TargetView()

  private lazy var driver = InteractiveZoomDriver(
    gestureTargetView: targetView,
    sourceView: targetView,
    targetViewFactory: { (fromImageView: TargetView) -> UIView in
      let view = UIView()
      view.backgroundColor = .lightGray
      return view
  },
    shouldZoomTransform: {(sourceView: TargetView) -> Bool in
      return true
  })

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    _ = driver

    targetView.backgroundColor = .darkGray
    targetView.frame = .init(x: 100, y: 100, width: 200, height: 200)
    view.addSubview(targetView)

    let button = UIButton()
    button.frame = .init(x: (view.bounds.width - 80) / 2, y: view.bounds.height - 120, width: 80, height: 40)
    button.setTitle("dismiss", for: .normal)
    button.setTitleColor(.darkText, for: .normal)
    button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
    view.addSubview(button)
  }

  @objc func didTap() {

    dismiss(animated: true, completion: nil)
  }

  deinit {
    print("deinit: ModalViewController")
  }

}


import SwiftUI

struct InteractiveZoomSwiftUIView_Previews: PreviewProvider {

  private static let imageView: UIImageView = {
    let image = UIImage(named: "sample1")!
    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.backgroundColor = .white
    imageView.layer.cornerRadius = 24.0
    return imageView
  }()

  static var previews: some View {
    TabView {
      if #available(iOS 16.0, *) {
        NavigationStack {

          ScrollView {
            VStack(spacing: 20) {
              Text("InteractiveZoomSwiftUIView")
                .font(.headline)

              InteractiveZoomSwiftUIView(sourceView: imageView)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .frame(width: 300, height: 300)
                .border(Color.gray)
            }
            .padding()
          }
          .navigationTitle(Text("Title"))
        }
        .tabItem {
          Text("Tab1")
        }
      }

      Text("Text")
        .tabItem {
          Text("Tab2")
        }

    }
  }
}
