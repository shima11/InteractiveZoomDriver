import SwiftUI
import UIKit

public struct InteractiveZoomSwiftUIView: UIViewRepresentable {

  private let image: UIImage
  private let cornerRadius: CGFloat

  public init(
    image: UIImage,
    cornerRadius: CGFloat
  ) {
    self.image = image
    self.cornerRadius = cornerRadius
  }

  public func makeUIView(context: Context) -> UIView {

    let containerView = UIView(frame: .zero)

    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = cornerRadius
    imageView.translatesAutoresizingMaskIntoConstraints = false

    let interactiveZoomView = InteractiveZoomView(
      sourceView: imageView,
      targetViewFactory: InteractiveZoomView.clone(from:),
      shouldZoomTransform: { _ in true }
    )
    interactiveZoomView.translatesAutoresizingMaskIntoConstraints = false

    containerView.addSubview(imageView)
    containerView.addSubview(interactiveZoomView)

    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
      imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      interactiveZoomView.topAnchor.constraint(equalTo: containerView.topAnchor),
      interactiveZoomView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      interactiveZoomView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      interactiveZoomView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    ])

    return containerView
  }

  public func updateUIView(_ uiView: UIView, context: Context) {
    print("updateUIView called")
  }
}

struct InteractiveZoomSwiftUIView_Previews: PreviewProvider {

  static let image = UIImage(systemName: "person")!

  static var previews: some View {
    TabView {
      if #available(iOS 16.0, *) {
        NavigationStack {

          ScrollView {
            VStack(spacing: 20) {
              Text("InteractiveZoomSwiftUIView")
                .font(.headline)

              InteractiveZoomSwiftUIView(image: image, cornerRadius: 24)
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

